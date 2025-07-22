# scripts/game/spawning/EnemyPool.gd
extends RefCounted
class_name EnemyPool

## FIXED: Manages collection of available enemies with separated budget vs combat scaling
## Budget power level = for spawn cost calculations (never changes)
## Combat scaling = applied when enemy spawns (via _apply_combat_scaling)

# ===== ENEMY COLLECTION =====
var all_enemies: Array[EnemyData] = []
var spawnable_enemies: Array[EnemyData] = []  # Cached filtered list
var special_enemies: Array[EnemyData] = []    # Golden Ship, etc.

# ===== CACHING =====
var cached_level: int = -1                    # Last level we filtered for

# ===== INITIALIZATION =====
func _init():
	_load_all_enemies()

func _load_all_enemies() -> void:
	"""Load all enemy scenes and create EnemyData with BUDGET power levels"""
	
	# FIXED: These are BUDGET power levels, used for spawn cost only
	# Combat scaling happens separately when enemy actually spawns
	
	# Early game enemies (affordable for small budgets)
	_add_enemy("res://scenes/actors/enemys/Biter.tscn", 1, 1, 25, "biter")
	_add_enemy("res://scenes/actors/enemys/Triangle.tscn", 2, 1, 25, "smart_ship") 
	_add_enemy("res://scenes/actors/enemys/Rectangle.tscn", 3, 2, 25, "smart_ship")
	
	# Mid-tier enemies (balanced progression)
	_add_enemy("res://scenes/actors/enemys/Tank.tscn", 4, 3, 25, "tank")
	_add_enemy("res://scenes/actors/enemys/Star.tscn", 4, 3, 25, "star")
	
	# Late game enemies (occasional high-value spawns)
	_add_enemy("res://scenes/actors/enemys/Diamond.tscn", 6, 5, 25, "diamond")
	_add_enemy("res://scenes/actors/enemys/Swarm.tscn", 5, 3, 25, "swarm")
	_add_enemy("res://scenes/actors/enemys/MotherShip.tscn", 8, 6, 25, "mother_ship")
	
	# Special spawning enemies
	_add_special_enemy("res://scenes/actors/enemys/GoldShip.tscn", 1, 1, 25, "gold_ship")

func _add_enemy(path: String, budget_power: int, min_lvl: int, max_lvl: int, type: String) -> void:
	"""Add a normal spawnable enemy with BUDGET power level"""
	var scene = load(path)
	if not scene:
		push_error("EnemyPool: Failed to load enemy scene: " + path)
		return
	
	# FIXED: Store budget power level (for spawn cost calculations)
	var enemy_data = EnemyData.new(scene, budget_power, min_lvl, max_lvl, type, "common", false)
	all_enemies.append(enemy_data)

func _add_special_enemy(path: String, budget_power: int, min_lvl: int, max_lvl: int, type: String) -> void:
	"""Add a special enemy with separate spawning logic"""
	var scene = load(path)
	if not scene:
		push_error("EnemyPool: Failed to load special enemy scene: " + path)
		return
	
	# FIXED: Store budget power level (for spawn cost calculations)
	var enemy_data = EnemyData.new(scene, budget_power, min_lvl, max_lvl, type, "special", true)
	special_enemies.append(enemy_data)

# ===== ENEMY FILTERING =====
func get_spawnable_enemies_for_level(level: int) -> Array[EnemyData]:
	"""Get all enemies that can spawn at the given level"""
	
	# Return cached result if same level
	if level == cached_level and not spawnable_enemies.is_empty():
		return spawnable_enemies
	
	# Filter enemies by level constraints
	spawnable_enemies.clear()
	for enemy in all_enemies:
		if enemy.can_spawn_at_level(level):
			spawnable_enemies.append(enemy)
	
	cached_level = level
	
	return spawnable_enemies

# ===== ENEMY SELECTION (FIXED: Uses budget power levels) =====
func get_random_enemy_within_budget(available_enemies: Array[EnemyData], remaining_budget: int) -> EnemyData:
	"""Get random enemy that fits in remaining budget - FIXED: Uses budget power level"""
	
	var valid_enemies: Array[EnemyData] = []
	for enemy in available_enemies:
		if enemy.get_budget_power_level() <= remaining_budget:  # FIXED: Use budget power level
			valid_enemies.append(enemy)
	
	if valid_enemies.is_empty():
		return null
	
	return valid_enemies[randi() % valid_enemies.size()]

func get_best_fit_enemy(available_enemies: Array[EnemyData], remaining_budget: int) -> EnemyData:
	"""Get enemy that best fits the remaining budget - FIXED: Uses budget power level"""
	
	var best_enemy: EnemyData = null
	var best_power: int = 0
	
	for enemy in available_enemies:
		var budget_power = enemy.get_budget_power_level()  # FIXED: Use budget power level
		if budget_power <= remaining_budget and budget_power > best_power:
			best_enemy = enemy
			best_power = budget_power
	
	return best_enemy

func get_exact_fit_enemy(available_enemies: Array[EnemyData], budget: int) -> EnemyData:
	"""Get enemy that exactly matches the budget - FIXED: Uses budget power level"""
	
	for enemy in available_enemies:
		if enemy.get_budget_power_level() == budget:  # FIXED: Use budget power level
			return enemy
	
	return null

# ===== SPECIAL ENEMIES =====
func get_special_enemies_for_level(level: int) -> Array[EnemyData]:
	"""Get special enemies (Golden Ship, etc.) for level"""
	var available_specials: Array[EnemyData] = []
	
	for enemy in special_enemies:
		if enemy.can_spawn_at_level(level):
			available_specials.append(enemy)
	
	return available_specials

# ===== DEBUG INFO =====
func get_pool_statistics() -> Dictionary:
	"""Get statistics about the enemy pool"""
	return {
		"total_enemies": all_enemies.size(),
		"special_enemies": special_enemies.size(),
		"cached_level": cached_level,
		"cached_spawnable": spawnable_enemies.size()
	}

func print_enemy_budget_breakdown() -> void:
	"""Debug: Print all enemies with their budget power levels"""
	print("\n=== ENEMY BUDGET BREAKDOWN ===")
	for enemy in all_enemies:
		print("%s: Budget Power = %d (Levels %d-%d)" % [
			enemy.get_scene_name(), 
			enemy.get_budget_power_level(),
			enemy.min_level,
			enemy.max_level
		])
	print("================================\n")
