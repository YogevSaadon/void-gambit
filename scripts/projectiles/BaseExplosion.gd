# scripts/projectiles/BaseExplosion.gd
extends Area2D
class_name BaseExplosion

# ====== Base Properties (configurable by children) ======
@export var damage: float = 20.0
@export var crit_chance: float = 0.0
@export var radius: float = 64.0
@export var target_group: String = "Enemies"  # Override in children
@export var explosion_collision_layer: int = CollisionLayers.LAYER_PLAYER_PROJECTILES   # Override in children
@export var explosion_collision_mask: int = CollisionLayers.LAYER_ENEMIES   # Override in children
@export var fade_duration: float = 0.15
@export var initial_color: Color = Color(1, 1, 1, 0.8)

var elapsed_time: float = 0.0
var current_color: Color

# ====== Built-in Methods ======
func _ready() -> void:
	set_monitoring(true)
	set_collision_properties()
	$CollisionShape2D.shape.radius = radius
	current_color = initial_color
	# Connect to both signals to handle Area2D and CharacterBody2D
	area_entered.connect(_on_collision)
	body_entered.connect(_on_collision)
	set_process(true)

func _process(delta: float) -> void:
	elapsed_time += delta
	var t = elapsed_time / fade_duration
	current_color.a = lerp(initial_color.a, 0.0, pow(t, 1.5))
	queue_redraw()

	if elapsed_time >= fade_duration:
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, current_color)

# ====== Hit Logic (handles both Area2D and CharacterBody2D) ======
func _on_collision(node: Node) -> void:
	if not node.is_in_group(target_group):
		return
	
	# Handle different damage methods for different targets
	if node.is_in_group("Player"):
		# Player uses receive_damage
		if node.has_method("receive_damage"):
			node.receive_damage(int(damage))
	else:
		# Enemies use apply_damage with crit system
		if node.has_method("apply_damage"):
			var is_crit = crit_chance > 0.0 and randf() < crit_chance
			node.apply_damage(damage, is_crit)

# ====== Collision Setup (uses configurable properties) ======
func set_collision_properties() -> void:
	collision_layer = 1 << explosion_collision_layer
	collision_mask = 1 << explosion_collision_mask
