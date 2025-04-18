extends Area2D
class_name Bullet

@export var speed: float = 400.0  # Movement speed
@export var lifetime: float = 3.0   # Time in seconds before auto-clear
var damage: float = 0            # Damage (set by weapon later on)
var piercing: int = 0               # How many enemies it can pass through (set by weapon)
var direction: Vector2 = Vector2.ZERO  # Normalized direction vector

func _enter_tree():
	collision_layer = 1 << 0  # Bullet on layer 1
	collision_mask = 1 << 1   # Collides with actors on layer 2

func _ready():
	connect("body_entered", Callable(self, "_on_Bullet_body_entered"))

func _physics_process(delta):
	# Move bullet
	position += direction * speed * delta
	rotation = direction.angle()
	# Decrease lifetime and clear when expired
	lifetime -= delta
	if lifetime <= 0:
		queue_free()

func _on_Bullet_body_entered(body: Node) -> void:
	if body.is_in_group("Enemies"):
		body.take_damage(damage)
		piercing -= 1
		if piercing < 0:
			queue_free()
