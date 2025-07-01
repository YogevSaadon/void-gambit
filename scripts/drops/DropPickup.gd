# res://scripts/pickups/DropPickup.gd
extends Area2D
class_name DropPickup

enum Currency { CREDIT, COIN }

@export var currency_type: Currency = Currency.CREDIT
@export var value: int = 1

const PICKUP_RADIUS   : float = 64.0
const PICKUP_THRESHOLD: float = 16.0
const MAX_SPEED       : float = 600.0
const ACCEL           : float = 2400.0

signal picked_up(amount: int, currency_type: int)

@onready var player : Player           = get_tree().get_first_node_in_group("Player")
@onready var shape  : CollisionShape2D = $CollisionShape2D
var velocity        : Vector2          = Vector2.ZERO

func _ready() -> void:
	if shape.shape is CircleShape2D:
		(shape.shape as CircleShape2D).radius = PICKUP_RADIUS
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	var to_player = player.global_position - global_position
	var dist      = to_player.length()

	if dist > PICKUP_RADIUS:
		return

	if dist < PICKUP_THRESHOLD:
		_collect()
		return

	var desired = to_player.normalized() * MAX_SPEED
	velocity    = velocity.move_toward(desired, ACCEL * delta)
	position   += velocity * delta

func _collect() -> void:
	var gm = get_tree().get_root().get_node("GameManager")
	if gm == null:
		push_error("DropPickup: GameManager not found")
		return

	# Single clean method that handles both currencies
	match currency_type:
		Currency.CREDIT:
			gm.add_credits(value)
		Currency.COIN:
			gm.add_coins(value)

	emit_signal("picked_up", value, currency_type)
	queue_free()
