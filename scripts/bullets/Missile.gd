# res://scripts/projectiles/Missile.gd
extends Area2D
class_name Missile

@export var speed:        float = 450.0
@export var damage:       float = 60.0
@export var radius:       float = 64.0
@export var crit_chance:  float = 0.05
@export var explosion_scene: PackedScene = preload("res://scenes/bullets/Explosion.tscn")

var target_position: Vector2
var exploded: bool = false                   # ← new guard

@onready var ttl_timer := $Timer

func _ready() -> void:
	collision_layer = 1 << 4
	collision_mask  = 1 << 2
	connect("body_entered",  Callable(self, "_on_Collision"))
	connect("area_entered",  Callable(self, "_on_Collision"))
	ttl_timer.connect("timeout", Callable(self, "_explode"))

func _physics_process(delta: float) -> void:
	if exploded:
		return
	var dir: Vector2 = (target_position - global_position).normalized()
	position += dir * speed * delta
	if global_position.distance_to(target_position) <= speed * delta:
		_explode()

func _on_Collision(_node: Node) -> void:
	_explode()

func _explode() -> void:
	if exploded:
		return                        # already did it
	exploded = true

	if explosion_scene:
		var expl := explosion_scene.instantiate()
		expl.position     = global_position
		expl.damage       = damage
		expl.radius       = radius
		expl.crit_chance  = crit_chance
		get_tree().current_scene.add_child(expl)

	queue_free()
