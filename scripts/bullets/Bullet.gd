extends Area2D
class_name Bullet

# ====== Exports ======
@export var speed: float = 600.0
var direction: Vector2 = Vector2.ZERO
var damage: float = 10.0
var piercing: int = 0

# ====== Built-in Methods ======

func _ready() -> void:
	set_collision_properties()
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

# ====== Collision Handling ======

func _on_body_entered(body: Node) -> void:

	if body.is_in_group("Enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

		piercing -= 1
		if piercing < 0:
			queue_free()

# ====== Utility ======

func set_collision_properties() -> void:
	collision_layer = 1 << 4    # Bullet on Layer 4
	collision_mask = 1 << 2     # Detect Enemies on Layer 2
