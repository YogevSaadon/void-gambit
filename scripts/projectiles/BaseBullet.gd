# scripts/projectiles/BaseBullet.gd
extends Area2D
class_name BaseBullet

# ====== Base Properties (configurable by children) ======
@export var speed: float = 1000.0
@export var max_lifetime: float = 2.0
@export var target_group: String = "Enemies"  # Override in children
@export var bullet_collision_layer: int = 4   # Override in children  
@export var bullet_collision_mask: int = 2    # Override in children

# ====== Runtime ======
var direction: Vector2 = Vector2.ZERO
var damage: float = 10.0
@onready var pd := get_tree().root.get_node("PlayerData")
var _time_alive: float = 0.0
var has_hit: bool = false

# ====== Built-in Methods ======
func _ready() -> void:
	set_collision_properties()
	# Connect to both signals to handle Area2D and CharacterBody2D
	area_entered.connect(_on_collision)
	body_entered.connect(_on_collision)

func _physics_process(delta: float) -> void:
	# Movement
	position += direction * speed * delta

	# Lifetime management
	_time_alive += delta
	if _time_alive >= max_lifetime:
		queue_free()

# ====== Hit Logic (handles both Area2D and CharacterBody2D) ======
func _on_collision(node: Node) -> void:
	if has_hit:
		return
		
	# Check if the node is in our target group
	if node.is_in_group(target_group):
		apply_hit(node)

func apply_hit(target: Node) -> void:
	has_hit = true
	if target.has_method("apply_damage"):
		var is_crit = randf() < pd.get_stat("crit_chance")
		target.apply_damage(damage, is_crit)
	queue_free()

# ====== Collision Setup (uses configurable properties) ======
func set_collision_properties() -> void:
	collision_layer = 1 << bullet_collision_layer
	collision_mask  = 1 << bullet_collision_mask
	monitoring = true
	monitorable = true
