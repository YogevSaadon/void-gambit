# scripts/actors/enemys/base-enemy/PowerIndicator.gd
extends Node2D
class_name PowerIndicator

@onready var rect := $ColorRect

func apply_power_level(tier_level: int) -> void:
	"""
	Updated for simple tier system - use game level to determine tier color
	"""
	# Get the current game level to determine tier
	var gm = get_tree().root.get_node_or_null("GameManager")
	var game_level = gm.level_number if gm else 1
	
	# Use simple tier system (every 5 levels)
	var color: Color = _get_simple_tier_color(game_level)
	
	# Apply the color
	rect.color = color
	
	# Add glow effect for higher tiers (level 11+)
	if game_level >= 11:
		_add_glow_effect(color)

func _get_simple_tier_color(level: int) -> Color:
	"""Simple tier color system matching WaveManager"""
	if level < 6:
		return Color.WHITE      # White tier: Levels 1-5
	elif level < 12:
		return Color.GREEN      # Green tier: Levels 6-11
	elif level < 18:
		return Color.CYAN       # Blue tier: Levels 12-17
	elif level < 24:
		return Color.MAGENTA    # Purple tier: Levels 18-23
	else:
		return Color.ORANGE     # Orange tier: Levels 24+

func _add_glow_effect(glow_color: Color) -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(rect, "modulate", glow_color * 1.3, 0.8)
	tween.tween_property(rect, "modulate", Color.WHITE, 0.8)
