# scripts/game/spawning/GoldenShipSpawner.gd
extends RefCounted
class_name GoldenShipSpawner

## Handles special Golden Ship spawning logic
## Golden Ships spawn separately from main power budget system

# ===== GOLDEN SHIP SCENE =====
const GOLDEN_SHIP_SCENE = preload("res://scenes/actors/enemys/GoldShip.tscn")

# ===== SPAWN TRACKING =====
var current_level: int = 1
var ships_to_spawn: int = 0
var ships_spawned_this_level: int = 0

# ===== MAIN SPAWNING METHOD =====
func generate_golden_ships(level: int, player_data: PlayerData) -> Array[PackedScene]:
	"""
	Generate Golden Ships for this level based on player's golden_ship_count stat
	Golden Ships spawn independently of power budget
	"""
	current_level = level
	ships_to_spawn = int(player_data.get_stat("golden_ship_count"))
	
	var spawn_list: Array[PackedScene] = []
	
	# Check if we've already spawned enough ships this level
	if ships_spawned_this_level >= ships_to_spawn:
		return spawn_list
	
	# Add one Golden Ship to spawn list if we haven't reached the limit
	if ships_to_spawn > 0:
		spawn_list.append(GOLDEN_SHIP_SCENE)
		ships_spawned_this_level += 1
		_print_golden_ship_summary()
	
	return spawn_list

# ===== LEVEL RESET =====
func reset_level_counter() -> void:
	"""Reset the counter when starting a new level"""
	ships_spawned_this_level = 0
	print("GoldenShipSpawner: Reset level counter for new level")

# ===== GOLDEN SHIP CONFIGURATION =====
func _print_golden_ship_summary() -> void:
	"""Print summary of Golden Ship spawning"""
	if ships_to_spawn <= 0:
		return
	
	var tier_multiplier = PowerBudgetCalculator.get_tier_multiplier(current_level)
	var tier_name = PowerBudgetCalculator.get_tier_name(current_level)
	var total_value = get_total_golden_ship_value(current_level)
	
	print("=== GOLDEN SHIPS Level %d ===" % current_level)
	print("Count: %d/%d ships (spawned/total)" % [ships_spawned_this_level, ships_to_spawn])
	print("Tier: %s (%dx multiplier)" % [tier_name, tier_multiplier])
	print("Total Value: %d power" % total_value)
	print("============================")

func apply_tier_scaling_to_golden_ship(golden_ship: Node, level: int) -> void:
	"""
	Apply tier scaling to a Golden Ship instance
	Call this when the Golden Ship is instantiated
	"""
	if not golden_ship:
		return
	
	var tier_multiplier = PowerBudgetCalculator.get_tier_multiplier(level)
	
	# Golden Ships use the same tier system as other enemies
	if golden_ship.has_method("apply_tier_scaling"):
		golden_ship.apply_tier_scaling(level)
	else:
		# Fallback: manual scaling
		var base_power = golden_ship.base_power_level if "base_power_level" in golden_ship else 1
		golden_ship.power_level = base_power * tier_multiplier
		if golden_ship.has_method("_apply_power_scale"):
			golden_ship._apply_power_scale()
	
	print("GoldenShip: Applied %dx tier scaling (level %d)" % [tier_multiplier, level])

# ===== UTILITY METHODS =====
func get_golden_ship_count() -> int:
	"""Get number of Golden Ships to spawn this level"""
	return ships_to_spawn

func should_spawn_golden_ships() -> bool:
	"""Check if any Golden Ships should spawn this tick"""
	return ships_spawned_this_level < ships_to_spawn

func get_total_golden_ship_value(level: int) -> int:
	"""Get total 'value' of Golden Ships (for balancing)"""
	if ships_to_spawn <= 0:
		return 0
	
	var tier_multiplier = PowerBudgetCalculator.get_tier_multiplier(level)
	var base_power = 1  # Golden Ships have base power 1
	var scaled_power = base_power * tier_multiplier
	
	return ships_to_spawn * scaled_power

# ===== SPAWN TIMING =====
func get_golden_ship_spawn_times(wave_duration: float) -> Array[float]:
	"""
	Get spawn times for Golden Ships spread throughout the wave
	Returns array of spawn times in seconds
	"""
	var spawn_times: Array[float] = []
	
	if ships_to_spawn <= 0:
		return spawn_times
	
	if ships_to_spawn == 1:
		# Single Golden Ship spawns at random time in middle 60% of wave
		var min_time = wave_duration * 0.2
		var max_time = wave_duration * 0.8
		spawn_times.append(randf_range(min_time, max_time))
	else:
		# Multiple Golden Ships spread evenly with some randomness
		var base_interval = wave_duration / (ships_to_spawn + 1)
		
		for i in ships_to_spawn:
			var base_time = base_interval * (i + 1)
			var variation = base_interval * 0.3  # ±30% variation
			var spawn_time = base_time + randf_range(-variation, variation)
			spawn_time = clamp(spawn_time, 0.0, wave_duration - 1.0)
			spawn_times.append(spawn_time)
	
	spawn_times.sort()  # Ensure chronological order
	return spawn_times

# ===== STATISTICS =====
func get_spawner_statistics() -> Dictionary:
	"""Get detailed statistics about Golden Ship spawning"""
	return {
		"level": current_level,
		"ships_to_spawn": ships_to_spawn,
		"ships_spawned": ships_spawned_this_level,
		"ships_remaining": ships_to_spawn - ships_spawned_this_level,
		"total_value": get_total_golden_ship_value(current_level),
		"tier_multiplier": PowerBudgetCalculator.get_tier_multiplier(current_level),
		"tier_name": PowerBudgetCalculator.get_tier_name(current_level)
	}

# ===== DEBUG METHODS =====
func print_spawn_schedule(wave_duration: float) -> void:
	"""Print Golden Ship spawn schedule for debugging"""
	var spawn_times = get_golden_ship_spawn_times(wave_duration)
	
	if spawn_times.is_empty():
		return
	
	print("=== GOLDEN SHIP SCHEDULE ===")
	print("Wave Duration: %.1fs" % wave_duration)
	for i in spawn_times.size():
		print("Ship %d: %.1fs" % [i + 1, spawn_times[i]])
	print("============================")
