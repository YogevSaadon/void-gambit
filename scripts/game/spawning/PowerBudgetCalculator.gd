# scripts/game/spawning/PowerBudgetCalculator.gd
extends RefCounted
class_name PowerBudgetCalculator

## Static utility class for power budget calculations
## Handles all math for the power-based enemy spawning system

# ===== POWER BUDGET CALCULATION =====
static func get_power_budget(level: int) -> int:
	"""
	Calculate total power budget for a level
	Level 1: 10 power
	Doubles every 5 levels: Level 5=20, Level 10=40, Level 15=80, etc.
	"""
	var base_budget: int = 10
	var level_group: int = (level - 1) / 5  # 0, 1, 2, 3, 4...
	var multiplier: int = int(pow(2, level_group))
	
	var final_budget = base_budget * multiplier
	
	print("PowerBudget Level %d: base=%d, group=%d, multiplier=%dx, final=%d" % [
		level, base_budget, level_group, multiplier, final_budget
	])
	
	return final_budget

# ===== TIER SCALING CALCULATION =====
static func get_tier_multiplier(level: int) -> int:
	"""
	Calculate tier multiplier for enemy scaling
	White(1x) → Green(2x) → Blue(4x) → Purple(8x) → Orange(16x)
	"""
	if level < 5:
		return 1    # White tier: Levels 1-4
	elif level < 10:
		return 2    # Green tier: Levels 5-9  
	elif level < 15:
		return 4    # Blue tier: Levels 10-14
	elif level < 20:
		return 8    # Purple tier: Levels 15-19
	else:
		return 16   # Orange tier: Levels 20+

static func get_tier_name(level: int) -> String:
	"""Get tier name for debugging/UI"""
	if level < 5: 
		return "White"
	elif level < 10: 
		return "Green"
	elif level < 15: 
		return "Blue" 
	elif level < 20: 
		return "Purple"
	else: 
		return "Orange"

static func get_tier_color(level: int) -> Color:
	"""Get tier color for visual effects"""
	if level < 5:
		return Color.WHITE
	elif level < 10:
		return Color.GREEN
	elif level < 15:
		return Color.CYAN
	elif level < 20:
		return Color.MAGENTA
	else:
		return Color.ORANGE

# ===== WAVE DURATION CALCULATION =====
static func get_wave_duration(level: int) -> float:
	"""
	Calculate wave duration based on level
	Level 1: 30 seconds
	Level 5: 60 seconds  
	Level 6+: 60 seconds (stays there)
	"""
	if level <= 1:
		return 30.0
	elif level >= 5:
		return 60.0
	else:
		# Linear interpolation from 30s to 60s over levels 1-5
		var progress = (level - 1) / 4.0  # 0.0 to 1.0
		return lerp(30.0, 60.0, progress)

# ===== SPAWN INTERVAL CALCULATION =====
static func get_spawn_interval(level: int, wave_duration: float, enemy_count: int) -> float:
	"""
	Calculate spawn interval to fit all enemies in wave duration
	Ensures we can actually spawn all enemies within the time limit
	"""
	if enemy_count <= 1:
		return 1.0
	
	# Leave 10% buffer time at the end
	var usable_time = wave_duration * 0.9
	var interval = usable_time / enemy_count
	
	# Minimum interval to prevent lag (max 10 enemies per second)
	return max(interval, 0.1)

# ===== DEBUG UTILITIES =====
static func get_level_info(level: int) -> Dictionary:
	"""Get all level information for debugging"""
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
	"""Print level progression for balancing"""
	print("=== LEVEL PROGRESSION ===")
	for level in range(start_level, end_level + 1):
		var info = get_level_info(level)
		print("Level %2d: %3d power, %s tier (%dx), %.0fs wave" % [
			info.level, info.power_budget, info.tier_name, 
			info.tier_multiplier, info.wave_duration
		])
	print("=========================")
