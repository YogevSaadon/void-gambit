# scripts/actors/enemys/base-enemy/PowerIndicator.gd
extends Node2D
class_name PowerIndicator

@onready var rect := $ColorRect

func apply_power_level(tier_level: int) -> void:
	var color: Color
	match tier_level:
		1:
			color = Color.WHITE
		2:
			color = Color.GREEN
		4:
			color = Color.CYAN
		8:
			color = Color.MAGENTA
		_:
			color = Color.ORANGE
	
	rect.color = color
	
	if tier_level >= 4:
		_add_glow_effect(color)

func _add_glow_effect(glow_color: Color) -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(rect, "modulate", glow_color * 1.3, 0.8)
	tween.tween_property(rect, "modulate", Color.WHITE, 0.8)
