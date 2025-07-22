# res://scripts/drops/DropPickup.gd
extends Area2D
class_name DropPickup

enum Currency { CREDIT, COIN }

@export var currency_type: Currency = Currency.CREDIT
@export var value: int = 1

# ===== ULTRA FAST PICKUP SETTINGS =====
const PICKUP_RADIUS: float = 120.0        # Large detection radius
const PICKUP_THRESHOLD: float = 15.0      # Collection threshold
const MIN_SPEED: float = 200.0            # Minimum movement speed
const MAX_SPEED: float = 2000.0           # MUCH faster maximum speed
const ACCELERATION_POWER: float = 3.0     # Cubic acceleration (t^3)
const DISTANCE_POWER: float = 2.5         # Exponential distance scaling
const PLAYER_SPEED_MULTIPLIER: float = 1.5 # Match fast players better

# ===== SMOOTH MOVEMENT VARIABLES =====
var target_player: Player = null
var pickup_active: bool = false
var velocity: Vector2 = Vector2.ZERO
var time_in_range: float = 0.0

signal picked_up(amount: int, currency_type: int)

@onready var shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	if shape.shape is CircleShape2D:
		(shape.shape as CircleShape2D).radius = PICKUP_RADIUS
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	# Find player if we don't have one
	if not target_player or not is_instance_valid(target_player):
		target_player = get_tree().get_first_node_in_group("Player")
		if not target_player:
			return
	
	var distance_to_player = global_position.distance_to(target_player.global_position)
	
	# ===== ACTIVATION CHECK =====
	if distance_to_player <= PICKUP_RADIUS:
		pickup_active = true
		time_in_range += delta
	
	if not pickup_active:
		return
	
	# ===== COLLECTION CHECK =====
	if distance_to_player <= PICKUP_THRESHOLD:
		_collect()
		return
	
	# ===== ULTRA AGGRESSIVE MAGNETIC MOVEMENT =====
	var direction = (target_player.global_position - global_position).normalized()
	
	# ===== EXPONENTIAL DISTANCE FACTOR =====
	# Close items move MUCH faster (exponential curve)
	var normalized_distance = distance_to_player / PICKUP_RADIUS  # 0.0 to 1.0
	var distance_factor = 1.0 - pow(normalized_distance, DISTANCE_POWER)  # Exponential curve
	
	# ===== TIME-BASED ACCELERATION =====
	# Items accelerate over time (cubic easing)
	var time_factor = pow(min(time_in_range * 2.0, 1.0), ACCELERATION_POWER)  # t^3 acceleration
	
	# ===== PLAYER SPEED MATCHING =====
	var player_velocity = target_player.velocity if "velocity" in target_player else Vector2.ZERO
	var player_speed_bonus = player_velocity.length() * PLAYER_SPEED_MULTIPLIER
	
	# ===== FINAL SPEED CALCULATION =====
	var base_speed = lerp(MIN_SPEED, MAX_SPEED, distance_factor * time_factor)
	var final_speed = base_speed + player_speed_bonus
	
	# Cap at maximum for safety
	final_speed = min(final_speed, MAX_SPEED)
	
	# ===== SMOOTH VELOCITY TRANSITION =====
	var target_velocity = direction * final_speed
	velocity = velocity.lerp(target_velocity, 8.0 * delta)  # Fast lerp for responsiveness
	
	# Apply movement
	global_position += velocity * delta

func _collect() -> void:
	var gm = get_tree().get_root().get_node("GameManager")
	if gm == null:
		push_error("DropPickup: GameManager not found")
		return

	match currency_type:
		Currency.CREDIT:
			gm.add_credits(value)
		Currency.COIN:
			gm.add_coins(value)

	emit_signal("picked_up", value, currency_type)
	queue_free()

# ===== EASING FUNCTIONS (Based on Robert Penner's formulas) =====
func ease_in_cubic(t: float) -> float:
	"""Cubic easing in - accelerating from zero velocity"""
	return t * t * t

func ease_in_expo(t: float) -> float:
	"""Exponential easing in - dramatic acceleration"""
	if t == 0.0:
		return 0.0
	return pow(2.0, 10.0 * (t - 1.0))

func ease_out_circ(t: float) -> float:
	"""Circular easing out - decelerating smoothly"""
	t -= 1.0
	return sqrt(1.0 - t * t)
