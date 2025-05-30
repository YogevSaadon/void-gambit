# res://scripts/pickups/DropPickup.gd
extends Area2D
class_name DropPickup

enum Currency { CREDIT, COIN }

# ── Configurable in the Inspector ─────────────────
@export var currency_type: Currency = Currency.CREDIT
@export var value: int           = 1

const PICKUP_RADIUS   : float = 64.0
const PICKUP_THRESHOLD: float = 16.0
const MAX_SPEED       : float = 600.0
const ACCEL           : float = 2400.0

signal picked_up(amount: int, currency_type: int)

# ── Internal ───────────────────────────────────────
@onready var player : Player           = get_tree().get_first_node_in_group("Player")
@onready var shape  : CollisionShape2D = $CollisionShape2D
var velocity        : Vector2          = Vector2.ZERO

func _ready() -> void:
	# set up our detection radius
	if shape.shape is CircleShape2D:
		(shape.shape as CircleShape2D).radius = PICKUP_RADIUS
	# physics tick
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	var to_player = player.global_position - global_position
	var dist      = to_player.length()

	# too far? wait
	if dist > PICKUP_RADIUS:
		return

	# close enough — collect!
	if dist < PICKUP_THRESHOLD:
		_collect()
		return

	# otherwise, home in smoothly
	var desired = to_player.normalized() * MAX_SPEED
	velocity    = velocity.move_toward(desired, ACCEL * delta)
	position   += velocity * delta


func _collect() -> void:
	# 1) find the GameManager
	var gm = get_tree().get_root().get_node("GameManager")
	if gm == null:
		push_error("DropPickup: GameManager not found at /root/GameManager")
		return

	# 2) award the right currency
	match currency_type:
		Currency.CREDIT:
			gm.add_credits(value)
		Currency.COIN:
			gm.add_coins(value)

	# 3) emit a signal if you want to listen elsewhere
	emit_signal("picked_up", value, currency_type)

	# 4) finally, remove the drop
	queue_free()
