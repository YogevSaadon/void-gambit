extends Area2D
class_name Bullet

# ====== Exports ======
@export var speed: float = 1000.0
@export var max_lifetime: float = 2.0   # seconds before auto‐free
var direction: Vector2 = Vector2.ZERO
var damage: float = 10.0
var piercing: int = 0

# ====== Runtime ======
@onready var pd := get_tree().root.get_node("PlayerData")
var _hit_enemies := {}    # Dictionary used as a Set
var _time_alive: float = 0.0

# ====== Built-in Methods ======
func _ready() -> void:
	set_collision_properties()
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float) -> void:
	# Movement
	position += direction * speed * delta

	# TTL
	_time_alive += delta
	if _time_alive >= max_lifetime:
		queue_free()

# ====== Collision Handling ======
func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("Enemies"):
		return

	# Skip if we've already hit this enemy
	if _hit_enemies.has(body):
		return
	_hit_enemies[body] = true

	# Apply damage
	if body.has_method("apply_damage"):
		var is_crit = randf() < pd.get_stat("crit_chance")
		body.apply_damage(damage, is_crit)

	# Handle piercing count
	piercing -= 1
	if piercing < 0:
		queue_free()

# ====== Utility ======
func set_collision_properties() -> void:
	collision_layer = 1 << 4    # Bullet on Layer 4
	collision_mask  = 1 << 2    # Detect Enemies on Layer 2
