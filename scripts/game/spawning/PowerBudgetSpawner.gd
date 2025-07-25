# scripts/game/spawning/PowerBudgetSpawner.gd
extends RefCounted
class_name PowerBudgetSpawner

## Main spawning algorithm that fills power budget with balanced enemy selection
## FIXED: Uses budget power level consistently, separates from tier scaling

# ===== DEPENDENCIES =====
var enemy_pool: EnemyPool

# ===== SPAWN TRACKING =====
var current_level: int = 1
var current_budget: int = 0
var spawned_power: int = 0
var spawn_list: Array[PackedScene] = []

# ===== CONFIGURATION =====
var budget_tolerance: float = 1.2  # Allow 20% overspend
var prefer_variety: bool = true     # Enable variety algorithm

# ===== VARIETY TRACKING =====
var enemy_type_counts: Dictionary = {}   # Track spawned enemy types for balance

# ===== INITIALIZATION =====
func _init():
	enemy_pool = EnemyPool.new()

# ===== MAIN SPAWNING METHOD =====
func generate_spawn_list(level: int) -> Array[PackedScene]:
	"""
	Generate list of enemies to spawn for this level with variety control
	FIXED: Uses budget power level consistently
	"""
	current_level = level
	current_budget = PowerBudgetCalculator.get_power_budget(level)
	
	# Reset tracking
	spawned_power = 0
	spawn_list.clear()
	enemy_type_counts.clear()
	
	# Get available enemies (no tier scaling applied here - that's for combat)
	var available_enemies = enemy_pool.get_spawnable_enemies_for_level(level)
	
	if available_enemies.is_empty():
		push_warning("PowerBudgetSpawner: No enemies available for level %d" % level)
		return spawn_list
	
	# Fill power budget using BUDGET power levels only
	_fill_power_budget_with_variety(available_enemies)
	
	# Randomize spawn order
	spawn_list.shuffle()
	
	return spawn_list

# ===== BUDGET FILLING ALGORITHM =====
func _fill_power_budget_with_variety(available_enemies: Array[EnemyData]) -> void:
	"""Fill power budget while maintaining enemy type variety"""
	
	var attempts = 0
	var max_attempts = 1000
	
	while spawned_power < current_budget and attempts < max_attempts:
		attempts += 1
		
		var remaining_budget = current_budget - spawned_power
		var selected_enemy = _select_enemy_with_variety(available_enemies, remaining_budget)
		
		if not selected_enemy:
			if _can_overspend(available_enemies, remaining_budget):
				selected_enemy = _select_overspend_enemy(available_enemies, remaining_budget)
			else:
				break
		
		if selected_enemy:
			_add_enemy_to_spawn_list(selected_enemy)
			var enemy_type = selected_enemy.enemy_type
			enemy_type_counts[enemy_type] = enemy_type_counts.get(enemy_type, 0) + 1
	
	if attempts >= max_attempts:
		push_warning("PowerBudgetSpawner: Hit max attempts, may have infinite loop")

func _select_enemy_with_variety(available_enemies: Array[EnemyData], remaining_budget: int) -> EnemyData:
	"""Select enemy while encouraging type variety - FIXED: Uses budget power level"""
	
	var valid_enemies: Array[EnemyData] = []
	for enemy in available_enemies:
		# FIXED: Use budget power level for budget calculations
		if enemy.get_budget_power_level() <= remaining_budget:
			valid_enemies.append(enemy)
	
	if valid_enemies.is_empty():
		return null
	
	# Prioritize exact budget fits for efficiency
	var exact_fit = _get_exact_fit_enemy(valid_enemies, remaining_budget)
	if exact_fit:
		return exact_fit
	
	# Apply variety preference if enabled and we have spawn history
	if prefer_variety and enemy_type_counts.size() > 0:
		var variety_enemies = _get_variety_preferred_enemies(valid_enemies)
		if not variety_enemies.is_empty():
			return variety_enemies[randi() % variety_enemies.size()]
	
	# Fallback to random selection
	return valid_enemies[randi() % valid_enemies.size()]

func _get_exact_fit_enemy(valid_enemies: Array[EnemyData], budget: int) -> EnemyData:
	"""Get enemy that exactly matches the budget - FIXED: Uses budget power level"""
	for enemy in valid_enemies:
		if enemy.get_budget_power_level() == budget:
			return enemy
	return null

func _get_variety_preferred_enemies(valid_enemies: Array[EnemyData]) -> Array[EnemyData]:
	"""Get enemies of underrepresented types for balanced spawning"""
	
	# Find minimum spawn count among current types
	var min_count = 999
	for enemy_type in enemy_type_counts:
		var count = enemy_type_counts[enemy_type]
		if count < min_count:
			min_count = count
	
	# Prefer enemies with count at or near minimum
	var preferred_enemies: Array[EnemyData] = []
	for enemy in valid_enemies:
		var current_count = enemy_type_counts.get(enemy.enemy_type, 0)
		if current_count <= min_count + 1:  # Allow slight imbalance
			preferred_enemies.append(enemy)
	
	return preferred_enemies

func _can_overspend(available_enemies: Array[EnemyData], remaining_budget: int) -> bool:
	"""Check if overspending is justified for better budget utilization"""
	var max_overspend = int(current_budget * budget_tolerance) - current_budget
	var remaining_ratio = float(remaining_budget) / float(current_budget)
	
	return remaining_ratio < 0.3 and max_overspend > 0

func _select_overspend_enemy(available_enemies: Array[EnemyData], remaining_budget: int) -> EnemyData:
	"""Select enemy for controlled overspending within tolerance - FIXED: Uses budget power level"""
	var max_total_power = int(current_budget * budget_tolerance)
	var max_enemy_power = max_total_power - spawned_power
	
	var overspend_candidates: Array[EnemyData] = []
	for enemy in available_enemies:
		var enemy_power = enemy.get_budget_power_level()  # FIXED: Use budget power level
		if enemy_power > remaining_budget and enemy_power <= max_enemy_power:
			overspend_candidates.append(enemy)
	
	if overspend_candidates.is_empty():
		return null
	
	return overspend_candidates[randi() % overspend_candidates.size()]

func _add_enemy_to_spawn_list(enemy_data: EnemyData) -> void:
	"""Add selected enemy to spawn list and update tracking - FIXED: Uses budget power level"""
	spawn_list.append(enemy_data.scene)
	spawned_power += enemy_data.get_budget_power_level()  # FIXED: Use budget power level

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

# ===== CONFIGURATION =====
func set_budget_tolerance(tolerance: float) -> void:
	"""Set overspending allowance (1.0 = no overspend, 1.2 = 20% overspend)"""
	budget_tolerance = max(1.0, tolerance)

func enable_variety_preference(enabled: bool) -> void:
	"""Enable or disable variety algorithm"""
	prefer_variety = enabled

func get_spawner_statistics() -> Dictionary:
	"""Get comprehensive statistics about spawning performance"""
	return {
		"level": current_level,
		"budget": current_budget,
		"spawned_power": spawned_power,
		"spawn_count": get_spawn_count(),
		"efficiency": get_spawn_efficiency(),
		"overspent": is_overspent(),
		"overspend_amount": get_overspend_amount(),
		"budget_tolerance": budget_tolerance,
		"enemy_variety": enemy_type_counts.duplicate()
	}
