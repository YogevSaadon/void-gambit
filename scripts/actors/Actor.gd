extends CharacterBody2D
class_name Actor

@export var max_health: int = 5
@export var health: int = 5
@export var shield: int = 0
@export var max_shield: int = 0
@export var speed: float = 0.0
@export var shield_recharge_rate: float = 0.0

var velocity_direction: Vector2 = Vector2.ZERO

func _enter_tree():
	collision_layer = 1 << 1   # Put Actor on layer 2.
	collision_mask = (1 << 0) | (1 << 2)  # Only collide with layers 1 and 3.


func move(direction: Vector2, _delta: float):  # Fix 1: Unused parameter warning
	velocity = direction * speed
	move_and_slide()

func take_damage(amount: int):
	if shield > 0:
		shield -= amount
		if shield < 0:
			health += shield  # Remaining damage carries over to health
			shield = 0
	else:
		health -= amount

	if health <= 0:
		destroy()

func destroy():
	queue_free()  # Default behavior; subclasses can override

func recharge_shield(delta: float):
	if shield < max_shield:
		shield = int(min(shield + shield_recharge_rate * delta, max_shield))  # Fix 2: Explicit int conversion
