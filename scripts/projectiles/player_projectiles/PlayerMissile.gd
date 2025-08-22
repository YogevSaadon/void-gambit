extends Area2D
class_name Missile

@export var speed:         float = 450.0
@export var damage:        float = 60.0
@export var radius:        float = 64.0
@export var crit_chance:   float = 0.05
@export var explosion_scene: PackedScene = preload("res://scenes/projectiles/player_projectiles/PlayerExplosion.tscn")

var target_position: Vector2
var exploded: bool = false

@onready var ttl_timer := $Timer

func _ready() -> void:
	collision_layer = 1 << CollisionLayers.LAYER_PLAYER_PROJECTILES
	collision_mask = 1 << CollisionLayers.LAYER_ENEMIES

	connect("body_entered",  Callable(self, "_on_Collision"))
	connect("area_entered",  Callable(self, "_on_Collision"))
	ttl_timer.connect("timeout", Callable(self, "_explode"))

func _physics_process(delta: float) -> void:
	if exploded:
		return

	var dir = (target_position - global_position).normalized()
	position += dir * speed * delta

	if global_position.distance_to(target_position) <= speed * delta:
		_explode()

func _on_Collision(_node: Node) -> void:
	_explode()

func _explode() -> void:
	if exploded:
		return
	exploded = true

	if explosion_scene:
		var expl = explosion_scene.instantiate()
		expl.position     = global_position
		expl.damage       = damage
		expl.radius       = radius
		expl.crit_chance  = crit_chance

		get_tree().current_scene.call_deferred("add_child", expl)

	call_deferred("queue_free")
