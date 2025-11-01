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
	var scaling_factor = 1.0 + (level - 1) * SpawningConstants.BUDGET_SCALING_PER_LEVEL
	var final_budget = int(SpawningConstants.BASE_BUDGET * scaling_factor)

	return final_budget

# ===== TIER SCALING CALCULATION =====
static func get_tier_multiplier(level: int) -> int:
	"""
	Calculate tier multiplier for enemy scaling with controlled progression
	White(1x) → Green(2x) → Blue(3x) → Purple(4x) → Orange(5x)
	"""
	if level < SpawningConstants.TIER_1_BREAKPOINT:
		return SpawningConstants.TIER_1_MULTIPLIER
	elif level < SpawningConstants.TIER_2_BREAKPOINT:
		return SpawningConstants.TIER_2_MULTIPLIER
	elif level < SpawningConstants.TIER_3_BREAKPOINT:
		return SpawningConstants.TIER_3_MULTIPLIER
	elif level < SpawningConstants.TIER_4_BREAKPOINT:
		return SpawningConstants.TIER_4_MULTIPLIER
	else:
		return SpawningConstants.TIER_5_MULTIPLIER

static func get_tier_name(level: int) -> String:
	"""Get tier name for debugging/UI"""
	if level < SpawningConstants.TIER_1_BREAKPOINT:
		return "White"
	elif level < SpawningConstants.TIER_2_BREAKPOINT:
		return "Green"
	elif level < SpawningConstants.TIER_3_BREAKPOINT:
		return "Blue"
	elif level < SpawningConstants.TIER_4_BREAKPOINT:
		return "Purple"
	else:
		return "Orange"

static func get_tier_color(level: int) -> Color:
	"""Get tier color for visual effects"""
	if level < SpawningConstants.TIER_1_BREAKPOINT:
		return Color.WHITE
	elif level < SpawningConstants.TIER_2_BREAKPOINT:
		return Color.GREEN
	elif level < SpawningConstants.TIER_3_BREAKPOINT:
		return Color.CYAN
	elif level < SpawningConstants.TIER_4_BREAKPOINT:
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
		return SpawningConstants.MIN_WAVE_DURATION
	elif level >= 5:
		return SpawningConstants.MAX_WAVE_DURATION
	else:
		var progress = (level - 1) / 4.0
		return lerp(SpawningConstants.MIN_WAVE_DURATION, SpawningConstants.MAX_WAVE_DURATION, progress)

# ===== SPAWN INTERVAL CALCULATION =====
static func get_spawn_interval(level: int, wave_duration: float, enemy_count: int) -> float:
	"""
	Calculate spawn interval to distribute enemies across wave duration
	Ensures all enemies can spawn within time limit with buffer
	"""
	if enemy_count <= 1:
		return 1.0

	var usable_time = wave_duration * SpawningConstants.USABLE_TIME_BUFFER
	var interval = usable_time / enemy_count

	return max(interval, SpawningConstants.MIN_SPAWN_INTERVAL)

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
	for level in range(start_level, end_level + 1):
		var info = get_level_info(level)
