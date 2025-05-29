extends Node
class_name PlayerMovement

@export var accel_time : float = 0.25      # time from 0 → max speed
@export var decel_time : float = 0.30      # time to bleed blink slide
@export var move_threshold_sq : float = 1.0  # squared pixels to consider “arrived”

var owner_player : Player = null
var blink_system : BlinkSystem = null
var current_vel  : Vector2 = Vector2.ZERO
var max_speed    : float = 0.0

var target_pos   : Vector2 = Vector2.ZERO
var moving       : bool = false
var blink_slide  : bool = false            # decel only used for blink

var lmb_prev   := false
var rmb_prev   := false
var space_prev := false            # ← NEW
var f_prev     := false            # ← NEW

# ------------------------------------------------------------
func initialize(p: Player) -> void:
	owner_player  = p
	blink_system  = p.get_node("BlinkSystem")
	max_speed     = p.speed
	target_pos    = p.global_position

# ------------------------------------------------------------
func physics_step(delta: float) -> void:
	var rmb   := Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	var lmb   := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var space := Input.is_key_pressed(KEY_SPACE)   # ← NEW
	var fkey  := Input.is_key_pressed(KEY_F)       # ← NEW

	# --- Blink (edge-trigger: LMB OR F) ----------------------
	if (lmb and not lmb_prev) or (fkey and not f_prev):       # ← CHANGED
		var blink_target = owner_player.get_global_mouse_position()
		var dir          = (blink_target - owner_player.global_position).normalized()
		blink_system.try_blink(blink_target)

		# give momentum in blink direction (keeps slide)
		current_vel = dir * max_speed
		blink_slide = true
		moving      = false
		target_pos  = owner_player.global_position

	# --- Keyboard SPACE: hold to chase cursor, stop on release
	if space:
		target_pos = owner_player.get_global_mouse_position()
		moving     = true
	elif space_prev and not space:
		moving      = false
		current_vel = Vector2.ZERO        # instant stop
		blink_slide = false               # no bleed after a manual stop

	# --- Mouse RMB (ignored while SPACE held) ---------------
	if not space:
		if rmb and not rmb_prev:
			target_pos = owner_player.get_global_mouse_position()
			moving     = true
		elif rmb:
			target_pos = owner_player.get_global_mouse_position()
			moving     = true

	# --- Desired velocity -----------------------------------
	var desired_vel := Vector2.ZERO
	if moving:
		var diff := target_pos - owner_player.global_position
		if diff.length_squared() <= move_threshold_sq:
			moving      = false
			current_vel = Vector2.ZERO      # stop instantly
		else:
			desired_vel = diff.normalized() * max_speed

	# --- Acceleration (only magnitude blends) ---------------
	if desired_vel.length_squared() > 0.0:
		var speed = current_vel.length()
		speed = lerp(speed, max_speed, clamp(delta / accel_time, 0.0, 1.0))
		current_vel = desired_vel.normalized() * speed
	elif blink_slide:
		# Decelerate blink momentum (slide bleed)
		var speed = current_vel.length()
		speed = lerp(speed, 0.0, clamp(delta / decel_time, 0.0, 1.0))
		if speed < 0.1:
			current_vel = Vector2.ZERO
			blink_slide = false
		else:
			current_vel = current_vel.normalized() * speed
	else:
		current_vel = Vector2.ZERO

	# --- Apply to CharacterBody2D ---------------------------
	owner_player.velocity = current_vel
	owner_player.move_and_slide()

	# --- Store previous states ------------------------------
	lmb_prev   = lmb
	rmb_prev   = rmb
	space_prev = space     # ← NEW
	f_prev     = fkey      # ← NEW
