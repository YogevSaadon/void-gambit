# scripts/game/spawning/EnemyPool.gd
extends RefCounted
class_name EnemyPool

## Manages collection of available enemies for spawning
## Handles filtering by level constraints and tier scaling

# ===== ENEMY COLLECTION =====
var all_enemies: Array[EnemyData] = []
var spawnable_enemies: Array[EnemyData] = []  # Cached filtered list
var special_enemies: Array[EnemyData] = []    # Golden Ship, etc.

# ===== CACHING =====
var cached_level: int = -1                    # Last level we filtered for
var cached_tier_multiplier: int = -1          # Last tier multiplier applied

# ===== INITIALIZATION =====
func _init():
	_load_all_enemies()

func _load_all_enemies() -> void:
	"""Load all enemy scenes and create EnemyData for each"""
	
	# Main spawnable enemies (normal power budget system)
	_add_enemy("res://scenes/actors/enemys/Biter.tscn", 1, 1, 25, "biter")
	_add_enemy("res://scenes/actors/enemys/Triangle.tscn", 2, 1, 25, "smart_ship") 
	_add_enemy("res://scenes/actors/enemys/Rectangle.tscn", 3, 2, 25, "smart_ship")
	_add_enemy("res://scenes/actors/enemys/Tank.tscn", 5, 4, 25, "tank")
	_add_enemy("res://scenes/actors/enemys/Star.tscn", 5, 3, 25, "star") 
	_add_enemy("res://scenes/actors/enemys/Diamond.tscn", 10, 6, 25, "diamond")
	_add_enemy("res://scenes/actors/enemys/MotherShip.tscn", 15, 8, 25, "mother_ship")
	_add_enemy("res://scenes/actors/enemys/Swarm.tscn", 10, 3, 25, "swarm")
	
	# Special enemies (separate spawning logic)
	_add_special_enemy("res://scenes/actors/enemys/GoldShip.tscn", 1, 1, 25, "gold_ship")
	
	# Spawned-only enemies (never spawn directly)
	# EnemyMissile, ChildShip, MiniBiter - excluded entirely
	
	print("EnemyPool: Loaded %d spawnable enemies, %d special enemies" % [
		all_enemies.size(), special_enemies.size()
	])

func _add_enemy(path: String, base_power: int, min_lvl: int, max_lvl: int, type: String) -> void:
	"""Add a normal spawnable enemy"""
	var scene = load(path)
	if not scene:
		push_error("EnemyPool: Failed to load enemy scene: " + path)
		return
	
	var enemy_data = EnemyData.new(scene, base_power, min_lvl, max_lvl, type, "common", false)
	all_enemies.append(enemy_data)

func _add_special_enemy(path: String, base_power: int, min_lvl: int, max_lvl: int, type: String) -> void:
	"""Add a special enemy (Golden Ship, etc.)"""
	var scene = load(path)
	if not scene:
		push_error("EnemyPool: Failed to load special enemy scene: " + path)
		return
	
	var enemy_data = EnemyData.new(scene, base_power, min_lvl, max_lvl, type, "special", true)
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
	
	print("EnemyPool: Level %d has %d available enemies" % [level, spawnable_enemies.size()])
	return spawnable_enemies

func apply_tier_scaling_to_all(tier_multiplier: int) -> void:
	"""Apply tier scaling to all enemies"""
	
	# Skip if already applied this multiplier
	if tier_multiplier == cached_tier_multiplier:
		return
	
	# Apply scaling to all enemies
	for enemy in all_enemies:
		enemy.apply_tier_scaling(tier_multiplier)
	
	for enemy in special_enemies:
		enemy.apply_tier_scaling(tier_multiplier)
	
	cached_tier_multiplier = tier_multiplier
	
	print("EnemyPool: Applied %dx tier scaling to all enemies" % tier_multiplier)

# ===== ENEMY SELECTION =====
func get_random_enemy_within_budget(available_enemies: Array[EnemyData], remaining_budget: int) -> EnemyData:
	"""Get random enemy that fits in remaining budget"""
	
	# Filter enemies that fit in budget
	var valid_enemies: Array[EnemyData] = []
	for enemy in available_enemies:
		if enemy.fits_in_budget(remaining_budget):
			valid_enemies.append(enemy)
	
	# Return random valid enemy, or null if none fit
	if valid_enemies.is_empty():
		return null
	
	return valid_enemies[randi() % valid_enemies.size()]

func get_best_fit_enemy(available_enemies: Array[EnemyData], remaining_budget: int) -> EnemyData:
	"""Get enemy that best fits the remaining budget (highest power that fits)"""
	
	var best_enemy: EnemyData = null
	var best_power: int = 0
	
	for enemy in available_enemies:
		if enemy.fits_in_budget(remaining_budget) and enemy.get_scaled_power() > best_power:
			best_enemy = enemy
			best_power = enemy.get_scaled_power()
	
	return best_enemy

func get_exact_fit_enemy(available_enemies: Array[EnemyData], budget: int) -> EnemyData:
	"""Get enemy that exactly matches the budget"""
	
	for enemy in available_enemies:
		if enemy.is_exact_fit(budget):
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
func print_available_enemies(level: int) -> void:
	"""Print all available enemies for debugging"""
	var available = get_spawnable_enemies_for_level(level)
	
	print("=== AVAILABLE ENEMIES Level %d ===" % level)
	for enemy in available:
		print("  %s" % enemy.to_debug_string())
	print("================================")

func get_pool_statistics() -> Dictionary:
	"""Get statistics about the enemy pool"""
	return {
		"total_enemies": all_enemies.size(),
		"special_enemies": special_enemies.size(),
		"cached_level": cached_level,
		"cached_spawnable": spawnable_enemies.size(),
		"tier_multiplier": cached_tier_multiplier
	}
