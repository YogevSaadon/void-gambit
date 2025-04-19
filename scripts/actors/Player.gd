extends "res://scripts/actors/Actor.gd"
class_name Player

# Unique Player Stats (Not in Actor)
@export var crit_chance: float = 5.0   # Percentage chance for critical hits
@export var luck: float = 1.0         # Affects item drop rate
@export var weapon_range: float = 500.0  # Max firing distance
@export var piercing: int = 0         # Bullet piercing count

# Movement target
var target_position: Vector2

func _ready() -> void:
	# Set Player‑Specific Stats
	health = 100
	max_health = 100
	shield = 50
	max_shield = 50
	shield_recharge_rate = 5.0
	speed = 200.0

	# Start movement target at current location
	target_position = global_position

func _input(event) -> void:
	# Right‑click to move
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		target_position = get_global_mouse_position()

func _physics_process(delta: float) -> void:
	# Move toward target if not already there
	if global_position.distance_to(target_position) > 3.0:
		var direction = (target_position - global_position).normalized()
		move(direction, delta)
	else:
		velocity = Vector2.ZERO
