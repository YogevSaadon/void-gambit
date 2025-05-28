extends Node
class_name PlayerMovement

@export var accel_time: float = 0.25
@export var decel_time: float = 0.30
@export var move_threshold_sq: float = 1.0

var owner_player: Player = null
var blink_system: BlinkSystem = null
var current_vel: Vector2 = Vector2.ZERO
var max_speed: float = 0.0

var target_pos: Vector2 = Vector2.ZERO
var moving: bool = false

var lmb_prev: bool = false
var rmb_prev: bool = false

func initialize(p: Player) -> void:
	owner_player = p
	blink_system = p.get_node("BlinkSystem")
	max_speed = p.speed
	target_pos = p.global_position

func physics_step(delta: float) -> void:
	var rmb = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	var lmb = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	# Blink on LMB edge (pressed this frame)
	if lmb and not lmb_prev:
		blink_system.try_blink(owner_player.get_global_mouse_position())
		current_vel = Vector2.ZERO
		moving = false
		target_pos = owner_player.global_position

	# Set/Update target on RMB click/hold or single press
	if rmb and not rmb_prev:
		target_pos = owner_player.get_global_mouse_position()
		moving = true
	elif rmb:
		target_pos = owner_player.get_global_mouse_position()
		moving = true

	var desired_vel: Vector2 = Vector2.ZERO
	if moving:
		var diff = target_pos - owner_player.global_position
		if diff.length_squared() <= move_threshold_sq:
			moving = false
			desired_vel = Vector2.ZERO
		else:
			desired_vel = diff.normalized() * max_speed

	# --- Instant turn, smooth speed ---
	if desired_vel.length_squared() > 0.0:
		# Face new direction instantly, blend only speed
		var speed = current_vel.length()
		speed = lerp(speed, max_speed, clamp(delta / accel_time, 0.0, 1.0))
		current_vel = desired_vel.normalized() * speed
	else:
		# Decelerate smoothly to a stop
		var speed = current_vel.length()
		speed = lerp(speed, 0.0, clamp(delta / decel_time, 0.0, 1.0))
		if speed < 0.1:
			current_vel = Vector2.ZERO
		else:
			current_vel = current_vel.normalized() * speed

	owner_player.velocity = current_vel
	owner_player.move_and_slide()

	lmb_prev = lmb
	rmb_prev = rmb
