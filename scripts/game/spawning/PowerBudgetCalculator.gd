# scripts/game/spawning/PowerBudgetCalculator.gd
extends RefCounted
class_name PowerBudgetCalculator

## Static utility class for power budget calculations
## Handles all math for the power-based enemy spawning system

# ===== POWER BUDGET CALCULATION =====
static func get_power_budget(level: int) -> int:
	"""
	Calculate total power budget for a level using gradual scaling
	Provides steady progression without exponential growth
	"""
	var base_budget: int = 10
	var scaling_factor = 1.0 + (level - 1) * 0.1  # 10% per level
	var final_budget = int(base_budget * scaling_factor)
	
	print("PowerBudget Level %d: base=%d, scaling=%.1fx, final=%d" % [
		level, base_budget, scaling_factor, final_budget
	])
	
	return final_budget

# ===== TIER SCALING CALCULATION =====
static func get_tier_multiplier(level: int) -> int:
	"""
	Calculate tier multiplier for enemy scaling with controlled progression
	White(1x) → Green(2x) → Blue(3x) → Purple(4x) → Orange(5x)
	"""
	if level < 6:
		return 1     # White tier: Levels 1-5
	elif level < 12:
		return 2     # Green tier: Levels 6-11
	elif level < 18:
		return 3     # Blue tier: Levels 12-17
	elif level < 24:
		return 4     # Purple tier: Levels 18-23
	else:
		return 5     # Orange tier: Levels 24+

static func get_tier_name(level: int) -> String:
	"""Get tier name for debugging/UI"""
	if level < 6: 
		return "White"
	elif level < 12: 
		return "Green"
	elif level < 18: 
		return "Blue" 
	elif level < 24: 
		return "Purple"
	else: 
		return "Orange"

static func get_tier_color(level: int) -> Color:
	"""Get tier color for visual effects"""
	if level < 6:
		return Color.WHITE
	elif level < 12:
		return Color.GREEN
	elif level < 18:
		return Color.CYAN
	elif level < 24:
		return Color.MAGENTA
	else:
		return Color.ORANGE

# ===== WAVE DURATION CALCULATION =====
static func get_wave_duration(level: int) -> float:
	"""
	Calculate wave duration based on level
	Gradually increases from 30s to 60s over first 5 levels
	"""
	if level <= 1:
		return 30.0
	elif level >= 5:
		return 60.0
	else:
		var progress = (level - 1) / 4.0
		return lerp(30.0, 60.0, progress)

# ===== SPAWN INTERVAL CALCULATION =====
static func get_spawn_interval(level: int, wave_duration: float, enemy_count: int) -> float:
	"""
	Calculate spawn interval to distribute enemies across wave duration
	Ensures all enemies can spawn within time limit with buffer
	"""
	if enemy_count <= 1:
		return 1.0
	
	var usable_time = wave_duration * 0.9  # 10% buffer
	var interval = usable_time / enemy_count
	
	return max(interval, 0.1)  # Minimum interval for performance

# ===== DEBUG UTILITIES =====
static func get_level_info(level: int) -> Dictionary:
	"""Get comprehensive level information for debugging"""
	var power_budget = get_power_budget(level)
	var tier_multiplier = get_tier_multiplier(level)
	var tier_name = get_tier_name(level)
	var tier_color = get_tier_color(level)
	var wave_duration = get_wave_duration(level)
	
	return {
		"level": level,
		"power_budget": power_budget,
		"tier_multiplier": tier_multiplier,
		"tier_name": tier_name,
		"tier_color": tier_color,
		"wave_duration": wave_duration
	}

static func print_level_progression(start_level: int = 1, end_level: int = 25) -> void:
	"""Print level progression for balancing analysis"""
	print("=== LEVEL PROGRESSION ===")
	for level in range(start_level, end_level + 1):
		var info = get_level_info(level)
		print("Level %2d: %3d power, %s tier (%dx), %.0fs wave" % [
			info.level, info.power_budget, info.tier_name, 
			info.tier_multiplier, info.wave_duration
		])
	print("==========================")
