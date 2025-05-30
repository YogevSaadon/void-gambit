extends Area2D
class_name Bullet

# ====== Exports ======
@export var speed: float = 1000.0
@export var max_lifetime: float = 2.0
var direction: Vector2 = Vector2.ZERO
var damage: float = 10.0

# ====== Runtime ======
@onready var pd := get_tree().root.get_node("PlayerData")
var _time_alive: float = 0.0
var has_hit: bool = false

# ====== Built-in Methods ======
func _ready() -> void:
	set_collision_properties()

func _physics_process(delta: float) -> void:
	# Movement
	position += direction * speed * delta

	# Lifetime management
	_time_alive += delta
	if _time_alive >= max_lifetime:
		queue_free()
		return

	# Hit detection
	if not has_hit:
		for body in get_overlapping_bodies():
			if body.is_in_group("Enemies"):
				apply_hit(body)
				break

# ====== Hit Logic ======
func apply_hit(enemy: Node) -> void:
	has_hit = true
	if enemy.has_method("apply_damage"):
		var is_crit = randf() < pd.get_stat("crit_chance")
		enemy.apply_damage(damage, is_crit)
	queue_free()

# ====== Collision Setup ======
func set_collision_properties() -> void:
	collision_layer = 1 << 4     # Bullet is on layer 4
	collision_mask  = 1 << 2     # Detect enemies on layer 2
	monitoring = true
	monitorable = true
