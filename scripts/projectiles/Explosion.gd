extends Area2D
class_name Explosion

@export var damage: float = 20.0
@export var crit_chance: float = 0.0
@export var radius: float = 64.0
@export var damage_group: String = "Enemies"
@export var fade_duration: float = 0.15
@export var initial_color: Color = Color(1, 1, 1, 0.8)

var elapsed_time: float = 0.0
var current_color: Color

func _ready() -> void:
	set_monitoring(true)
	set_collision_properties()
	$CollisionShape2D.shape.radius = radius
	current_color = initial_color
	connect("body_entered", _on_body_entered)
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

func set_collision_properties() -> void:
	collision_layer = 1 << 4    # explosion layer
	collision_mask = 1 << 2     # detect enemies

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group(damage_group):
		return
	if not body.has_method("apply_damage"):
		return

	var is_crit = crit_chance > 0.0 and randf() < crit_chance
	body.apply_damage(damage, is_crit)
