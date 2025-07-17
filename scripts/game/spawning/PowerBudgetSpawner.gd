# scripts/game/spawning/PowerBudgetSpawner.gd
extends RefCounted
class_name PowerBudgetSpawner

## Main spawning algorithm that fills power budget with random enemies
## Replaces the old simple enemy selection in WaveManager

# ===== DEPENDENCIES =====
var enemy_pool: EnemyPool

# ===== SPAWN TRACKING =====
var current_level: int = 1
var current_budget: int = 0
var spawned_power: int = 0
var spawn_list: Array[PackedScene] = []

# ===== SETTINGS =====
var budget_tolerance: float = 1.2  # Allow 20% overspend
var prefer_variety: bool = true     # Try to spawn different enemy types

# ===== INITIALIZATION =====
func _init():
	enemy_pool = EnemyPool.new()

# ===== MAIN SPAWNING METHOD =====
func generate_spawn_list(level: int) -> Array[PackedScene]:
	"""
	Generate list of enemies to spawn for this level
	Returns array of PackedScenes ready for instantiation
	"""
	current_level = level
	current_budget = PowerBudgetCalculator.get_power_budget(level)
	var tier_multiplier = PowerBudgetCalculator.get_tier_multiplier(level)
	
	# Reset tracking
	spawned_power = 0
	spawn_list.clear()
	
	# Get available enemies and apply tier scaling
	var available_enemies = enemy_pool.get_spawnable_enemies_for_level(level)
	enemy_pool.apply_tier_scaling_to_all(tier_multiplier)
	
	if available_enemies.is_empty():
		push_warning("PowerBudgetSpawner: No enemies available for level %d" % level)
		return spawn_list
	
	# Fill power budget with random enemies
	_fill_power_budget(available_enemies)
	
	# Shuffle for variety
	spawn_list.shuffle()
	
	_print_spawn_summary()
	return spawn_list

# ===== BUDGET FILLING ALGORITHM =====
func _fill_power_budget(available_enemies: Array[EnemyData]) -> void:
	"""Fill power budget by randomly selecting enemies"""
	
	var attempts = 0
	var max_attempts = 1000  # Prevent infinite loops
	
	while spawned_power < current_budget and attempts < max_attempts:
		attempts += 1
		
		var remaining_budget = current_budget - spawned_power
		var selected_enemy = _select_enemy(available_enemies, remaining_budget)
		
		if not selected_enemy:
			# No more enemies fit - check if we can overspend slightly
			if _can_overspend(available_enemies, remaining_budget):
				selected_enemy = _select_overspend_enemy(available_enemies, remaining_budget)
			else:
				break  # Budget filled as much as possible
		
		if selected_enemy:
			_add_enemy_to_spawn_list(selected_enemy)
	
	if attempts >= max_attempts:
		push_warning("PowerBudgetSpawner: Hit max attempts, may have infinite loop")

func _select_enemy(available_enemies: Array[EnemyData], remaining_budget: int) -> EnemyData:
	"""Select an enemy that fits in remaining budget"""
	
	# Try exact fit first (perfect budget usage)
	var exact_fit = enemy_pool.get_exact_fit_enemy(available_enemies, remaining_budget)
	if exact_fit:
		return exact_fit
	
	# Otherwise get random enemy that fits
	return enemy_pool.get_random_enemy_within_budget(available_enemies, remaining_budget)

func _can_overspend(available_enemies: Array[EnemyData], remaining_budget: int) -> bool:
	"""Check if we should allow overspending to fill budget better"""
	var max_overspend = int(current_budget * budget_tolerance) - current_budget
	
	# Only overspend if remaining budget is small compared to total
	var remaining_ratio = float(remaining_budget) / float(current_budget)
	return remaining_ratio < 0.3 and max_overspend > 0

func _select_overspend_enemy(available_enemies: Array[EnemyData], remaining_budget: int) -> EnemyData:
	"""Select enemy for overspending (within tolerance)"""
	var max_total_power = int(current_budget * budget_tolerance)
	var max_enemy_power = max_total_power - spawned_power
	
	# Find enemies that fit in overspend allowance
	var overspend_candidates: Array[EnemyData] = []
	for enemy in available_enemies:
		var enemy_power = enemy.get_scaled_power()
		if enemy_power > remaining_budget and enemy_power <= max_enemy_power:
			overspend_candidates.append(enemy)
	
	if overspend_candidates.is_empty():
		return null
	
	return overspend_candidates[randi() % overspend_candidates.size()]

func _add_enemy_to_spawn_list(enemy_data: EnemyData) -> void:
	"""Add selected enemy to spawn list and update tracking"""
	spawn_list.append(enemy_data.scene)
	spawned_power += enemy_data.get_scaled_power()

# ===== UTILITY METHODS =====
func get_spawn_efficiency() -> float:
	"""Get how efficiently we used the power budget (0.0 to 1.0+)"""
	if current_budget == 0:
		return 1.0
	return float(spawned_power) / float(current_budget)

func get_spawn_count() -> int:
	"""Get total number of enemies in spawn list"""
	return spawn_list.size()

func is_overspent() -> bool:
	"""Check if we overspent the budget"""
	return spawned_power > current_budget

func get_overspend_amount() -> int:
	"""Get amount overspent (0 if not overspent)"""
	return max(0, spawned_power - current_budget)

# ===== DEBUG OUTPUT =====
func _print_spawn_summary() -> void:
	"""Print summary of spawning results"""
	var efficiency = get_spawn_efficiency()
	var overspend = get_overspend_amount()
	
	print("=== SPAWN SUMMARY Level %d ===" % current_level)
	print("Budget: %d power" % current_budget)
	print("Spawned: %d power (%d enemies)" % [spawned_power, get_spawn_count()])
	print("Efficiency: %.1f%%" % (efficiency * 100.0))
	if overspend > 0:
		print("Overspend: +%d power (%.1f%%)" % [overspend, (float(overspend) / current_budget) * 100.0])
	print("============================")

func print_detailed_spawn_list() -> void:
	"""Print detailed breakdown of spawned enemies"""
	if spawn_list.is_empty():
		print("No enemies in spawn list")
		return
	
	print("=== DETAILED SPAWN LIST ===")
	var enemy_counts: Dictionary = {}
	
	# Count each enemy type
	for scene in spawn_list:
		var scene_name = scene.resource_path.get_file().get_basename()
		enemy_counts[scene_name] = enemy_counts.get(scene_name, 0) + 1
	
	# Print counts
	for enemy_name in enemy_counts:
		print("  %s: %d" % [enemy_name, enemy_counts[enemy_name]])
	print("===========================")

# ===== ADVANCED FEATURES (For Future) =====
func set_budget_tolerance(tolerance: float) -> void:
	"""Set how much overspending is allowed (1.0 = no overspend, 1.2 = 20% overspend)"""
	budget_tolerance = max(1.0, tolerance)

func enable_variety_preference(enabled: bool) -> void:
	"""Enable/disable preference for enemy variety (future feature)"""
	prefer_variety = enabled

func get_spawner_statistics() -> Dictionary:
	"""Get detailed statistics about spawning"""
	return {
		"level": current_level,
		"budget": current_budget,
		"spawned_power": spawned_power,
		"spawn_count": get_spawn_count(),
		"efficiency": get_spawn_efficiency(),
		"overspent": is_overspent(),
		"overspend_amount": get_overspend_amount(),
		"budget_tolerance": budget_tolerance
	}
