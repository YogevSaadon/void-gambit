extends CharacterBody2D
class_name Actor

# ====== Exports ======
@export var max_health: int = 5
@export var health: int = 5
@export var shield: int = 0
@export var max_shield: int = 0
@export var speed: float = 0.0
@export var shield_recharge_rate: float = 0.0

# ====== Constants ======
const PLAYER_LAYER = 1
const ENEMY_LAYER = 2

# ====== Runtime Variables ======
var velocity_direction: Vector2 = Vector2.ZERO

# ====== Built-in Methods ======

func _enter_tree() -> void:
	# Set up collision layers/masks via code
	collision_layer = 1 << ENEMY_LAYER
	collision_mask = (1 << 0) | (1 << PLAYER_LAYER)

func move(direction: Vector2, _delta: float) -> void:
	velocity = direction * speed
	move_and_slide()

func take_damage(amount: int) -> void:
	if shield > 0:
		shield -= amount
		if shield < 0:
			health += shield  # Remaining damage spills to health
			shield = 0
	else:
		health -= amount

	if health <= 0:
		destroy()

func destroy() -> void:
	queue_free()  # Default behavior; subclasses can override

func recharge_shield(delta: float) -> void:
	if shield < max_shield:
		shield = int(min(shield + shield_recharge_rate * delta, max_shield))
