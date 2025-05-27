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
		# Just pressed: set a new target (for click-to-move)
		target_pos = owner_player.get_global_mouse_position()
		moving = true
	elif rmb:
		# Holding: update target to current mouse for "chase" feel
		target_pos = owner_player.get_global_mouse_position()
		moving = true

	var desired_vel: Vector2 = Vector2.ZERO
	if moving:
		var diff = target_pos - owner_player.global_position
		var arrived = diff.length_squared() <= move_threshold_sq

		if arrived:
			moving = false
			desired_vel = Vector2.ZERO
		else:
			desired_vel = diff.normalized() * max_speed


	# Acceleration/Deceleration
	var accel_rate = max_speed / max(accel_time, 0.001)
	var decel_rate = max_speed / max(decel_time, 0.001)
	var rate = accel_rate if desired_vel.length_squared() > 0.0 else decel_rate

	var to_target = desired_vel - current_vel
	var max_change = rate * delta
	current_vel += to_target.limit_length(max_change)

	# Zero-out small drifts if not moving
	if not moving and current_vel.length_squared() < move_threshold_sq:
		current_vel = Vector2.ZERO

	owner_player.velocity = current_vel
	owner_player.move_and_slide()

	# Store button state for next frame (edge detection)
	lmb_prev = lmb
	rmb_prev = rmb
