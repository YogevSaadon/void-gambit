# scripts/actors/player/PlayerMovement.gd
extends Node
class_name PlayerMovement

# ===== MOVEMENT CONFIGURATION =====
@export var accel_time: float        = 0.25  # Time to reach max speed
@export var decel_time: float        = 0.30  # Time to decelerate from blink
@export var arrival_threshold: float = 8.0   # Consider "arrived" when this close
@export var movement_smoothing: float = 12.0 # Target‑pos lerp factor
@export var slowdown_distance: float  = 40.0 # Start slowing this close to target

# ===== ROTATION CONFIGURATION =====
@export var rotation_speed: float          = 8.0
@export var min_velocity_for_rotation: float = 30.0

# ===== INTERNAL STATE =====
var owner_player: Player     = null
var blink_system: BlinkSystem = null
var max_speed: float         = 0.0

# Movement state
var current_vel: Vector2 = Vector2.ZERO
var target_pos: Vector2  = Vector2.ZERO
var target_pos_smooth: Vector2 = Vector2.ZERO
var moving: bool         = false
var blink_slide: bool    = false
var movement_locked: bool = false

# Input state
var lmb_prev: bool   = false
var rmb_prev: bool   = false
var space_prev: bool = false
var f_prev: bool     = false

# ===== INITIALISE =====
func initialize(p: Player) -> void:
	owner_player = p
	blink_system = p.get_node("BlinkSystem")
	max_speed    = p.speed

	target_pos        = p.global_position
	target_pos_smooth = p.global_position

# ===== FRAME STEP (call from _physics_process) =====
func physics_step(delta: float) -> void:
	var rmb   = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	var lmb   = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var space = Input.is_key_pressed(KEY_SPACE)
	var fkey  = Input.is_key_pressed(KEY_F)

	# ===== BLINK INPUT =====
	if (lmb and not lmb_prev) or (fkey and not f_prev):
		var blink_target = owner_player.get_global_mouse_position()
		var dir = (blink_target - owner_player.global_position).normalized()

		# Momentum only if blink succeeded
		if blink_system.try_blink(blink_target):
			current_vel  = dir * max_speed
			blink_slide  = true
			_stop_movement()

	# ===== SPACE: FOLLOW CURSOR =====
	if space:
		_start_movement_to(owner_player.get_global_mouse_position())
	elif space_prev and not space:
		_stop_movement_immediately()

	# ===== RMB: CLICK‑TO‑MOVE =====
	if not space:
		if rmb and not rmb_prev:
			_start_movement_to(owner_player.get_global_mouse_position())
		elif rmb and moving:
			target_pos_smooth = owner_player.get_global_mouse_position()

	# ===== MOVEMENT UPDATE =====
	_update_target_smoothing(delta)
	_update_movement_physics(delta)
	_update_rotation(delta)

	# Apply movement
	owner_player.velocity = current_vel
	owner_player.move_and_slide()

	# Store previous input states
	lmb_prev   = lmb
	rmb_prev   = rmb
	space_prev = space
	f_prev     = fkey

# ===== MOVEMENT CONTROL =====
func _start_movement_to(new_target: Vector2) -> void:
	target_pos_smooth = new_target
	moving            = true
	movement_locked   = false
	blink_slide       = false

func _stop_movement() -> void:
	moving            = false
	movement_locked   = true
	target_pos        = owner_player.global_position
	target_pos_smooth = target_pos

func _stop_movement_immediately() -> void:
	moving            = false
	movement_locked   = true
	blink_slide       = false
	current_vel       = Vector2.ZERO
	target_pos        = owner_player.global_position
	target_pos_smooth = target_pos

# ===== CORE MOVEMENT LOGIC =====
func _update_target_smoothing(delta: float) -> void:
	if moving and not movement_locked:
		target_pos = target_pos.lerp(target_pos_smooth, movement_smoothing * delta)

		# Snap when almost there
		if target_pos.distance_to(target_pos_smooth) < 2.0:
			target_pos = target_pos_smooth

func _update_movement_physics(delta: float) -> void:
	var desired_vel: Vector2 = Vector2.ZERO

	if moving and not movement_locked:
		var diff     = target_pos - owner_player.global_position
		var distance = diff.length()

		# Arrival check
		if distance <= arrival_threshold:
			_stop_movement()
			return

		# Desired velocity
		var direction = diff.normalized()
		var speed     = max_speed

		# Smooth slowdown
		if distance < slowdown_distance:
			var slowdown_factor = smoothstep(0.0, 1.0, distance / slowdown_distance)
			speed *= max(slowdown_factor, 0.1)

		desired_vel = direction * speed

	# Velocity blending
	if desired_vel.length() > 0.0:
		var acceleration_rate = 1.0 / accel_time
		current_vel = current_vel.move_toward(desired_vel, max_speed * acceleration_rate * delta)
	elif blink_slide:
		var deceleration_rate = 1.0 / decel_time
		current_vel = current_vel.move_toward(Vector2.ZERO, max_speed * deceleration_rate * delta)

		if current_vel.length() < 10.0:
			current_vel   = Vector2.ZERO
			blink_slide   = false
			movement_locked = true
	else:
		current_vel = Vector2.ZERO

func _update_rotation(delta: float) -> void:
	if current_vel.length() > min_velocity_for_rotation and not movement_locked:
		var target_rot = current_vel.angle()
		owner_player.rotation = lerp_angle(owner_player.rotation, target_rot, rotation_speed * delta)

# ===== DEBUG =====
func get_debug_info() -> Dictionary:
	return {
		"moving": moving,
		"movement_locked": movement_locked,
		"blink_slide": blink_slide,
		"velocity": current_vel.length(),
		"distance_to_target": owner_player.global_position.distance_to(target_pos) if moving else 0.0
	}
