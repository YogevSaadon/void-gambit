extends Node
class_name PlayerMovement

# ── Tunables (seconds to/from max speed) ──────────────────────
@export var accel_time  : float = 0.25   # 0 → max speed
@export var decel_time  : float = 0.30   # max speed → 0
@export var move_threshold_sq : float = 1.0

# ── Runtime state ─────────────────────────────────────────────
var owner_player : Player      = null
var blink_system : BlinkSystem = null
var current_vel  : Vector2     = Vector2.ZERO
var max_speed    : float       = 0.0
var _lmb_prev    : bool        = false     # previous frame LMB state

# ── One-time setup ────────────────────────────────────────────
func initialize(p: Player) -> void:
	owner_player  = p
	blink_system  = p.get_node("BlinkSystem")
	max_speed     = p.speed

# ── Per-physics-frame update ──────────────────────────────────
func physics_step(delta: float) -> void:
	# 1. Input ------------------------------------------------------
	var rmb: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	var lmb: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	# Edge-detect blink
	if lmb and not _lmb_prev:
		blink_system.try_blink(owner_player.get_global_mouse_position())
		current_vel = Vector2.ZERO                       # halt after blink
	_lmb_prev = lmb

	# 2. Desired velocity ------------------------------------------
	var desired_vel: Vector2 = Vector2.ZERO
	if rmb:
		var dir: Vector2 = (owner_player.get_global_mouse_position() -
							owner_player.global_position).normalized()
		desired_vel = dir * max_speed

	# 3. Accel / decel rate (units: px/s²) -------------------------
	var accel_rate : float = max_speed / max(accel_time, 0.001)
	var decel_rate : float = max_speed / max(decel_time, 0.001)
	var rate       : float = accel_rate if desired_vel.length_squared() > 0.0 else decel_rate

	# 4. Blend toward desired --------------------------------------
	var to_target : Vector2 = desired_vel - current_vel
	var max_change: float   = rate * delta
	current_vel              += to_target.limit_length(max_change)

	# Clamp tiny drift
	if current_vel.length_squared() < move_threshold_sq:
		current_vel = Vector2.ZERO

	# 5. Apply to CharacterBody2D ----------------------------------
	owner_player.velocity = current_vel
	owner_player.move_and_slide()
