# scripts/actors/enemys/base-enemy/PowerIndicator.gd
extends Node2D
class_name PowerIndicator

@onready var rect := $ColorRect

func apply_power_level(tier_level: int) -> void:
	"""
	FIXED: Use actual game level to determine tier color, not enemy power level
	This ensures all enemies show the correct tier color regardless of their individual power
	"""
	# Get the current game level to determine tier
	var gm = get_tree().root.get_node_or_null("GameManager")
	var game_level = gm.level_number if gm else 1
	
	# Use the level-based tier system instead of individual enemy power
	var color: Color = PowerBudgetCalculator.get_tier_color(game_level)
	
	# Apply the color
	rect.color = color
	
	# Add glow effect for higher tiers (level 11+)
	if game_level >= 11:
		_add_glow_effect(color)

func _add_glow_effect(glow_color: Color) -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(rect, "modulate", glow_color * 1.3, 0.8)
	tween.tween_property(rect, "modulate", Color.WHITE, 0.8)
