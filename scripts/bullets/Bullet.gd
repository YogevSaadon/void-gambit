extends Area2D
class_name Bullet

@export var speed: float = 400.0
@export var lifetime: float = 3.0

var damage: float = 0.0
var piercing: int = 0
var direction: Vector2 = Vector2.ZERO

func _enter_tree():
	collision_layer = 1 << 0
	collision_mask = 1 << 1

func _ready():
	connect("body_entered", Callable(self, "_on_Bullet_body_entered"))

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	rotation = direction.angle()
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_Bullet_body_entered(body: Node) -> void:
	if body.is_in_group("Enemies"):
		body.take_damage(damage)
		piercing -= 1
		if piercing < 0:
			queue_free()
