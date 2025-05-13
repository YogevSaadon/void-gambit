extends Area2D
class_name Explosion

@export var damage: float = 20.0
@export var crit_chance: float = 0.0
@export var radius: float = 64.0
@export var damage_group: String = "Enemies"
@export var fade_duration: float = 0.15              # how long the flash lasts
@export var initial_color: Color = Color(1, 1, 1, 0.8)

#–– Internal state ––
var elapsed_time: float = 0.0
var current_color: Color

func _ready() -> void:
	$CollisionShape2D.shape.radius = radius
	set_collision_properties()
	# 1) Configure the collision area
	$CollisionShape2D.shape.radius = radius
	set_monitoring(true)       # start detecting overlaps immediately
	
	# 2) Initialize color
	current_color = initial_color
	
	# 3) Defer damage so physics bodies are registered
	call_deferred("_apply_damage")
	
	# 4) Turn on processing for fade
	set_process(true)

func set_collision_properties() -> void:
	collision_layer = 1 << 4    # explosion on Layer 4
	collision_mask = 1 << 2     # Detect Enemies on Layer 2

func _process(delta: float) -> void:
	elapsed_time += delta
	var t = elapsed_time / fade_duration
	
	# Fade alpha from initial to 0
	current_color.a = lerp(initial_color.a, 0.0, pow(t, 1.5))
	queue_redraw()
	
	# End of life
	if elapsed_time >= fade_duration:
		queue_free()

func _draw() -> void:
	# draw with the current fading color
	draw_circle(Vector2.ZERO, radius, current_color)

func _apply_damage() -> void:
	var bodies = get_overlapping_bodies()
	print("🧨 Explosion Overlapping Bodies: ", bodies.size())
	# iterate overlaps once
	for body in get_overlapping_bodies():
		if not body.is_in_group(damage_group):
			continue
		if not body.has_method("take_damage"):
			continue
		
		var final_damage = damage
		if crit_chance > 0.0 and randf() < crit_chance:
			final_damage *= 2.0
		
		body.take_damage(final_damage)
