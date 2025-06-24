# scripts/game/managers/TargetingManager.gd
extends Node
class_name TargetingManager

# ===== SPATIAL HASH CONFIGURATION =====
var cell_size: float = 256.0  # Will adapt based on weapon range
var hash_table: Dictionary = {}  # cell_id -> Array[BaseEnemy]
var always_check_enemies: Array[BaseEnemy] = []  # Teleporting enemies bypass spatial hash

# ===== RANGE TRACKING =====
var player_data: PlayerData = null
var last_weapon_range: float = 0.0
var range_change_threshold: float = 0.5  # Rebuild hash if range changes >50%

# ===== PERFORMANCE STATS =====
var total_enemies: int = 0
var spatial_hash_enemies: int = 0
var bypass_enemies: int = 0

func initialize(pd: PlayerData) -> void:
	player_data = pd
	last_weapon_range = pd.get_stat("weapon_range")
	_update_cell_size()
	
	print("TargetingManager initialized - Cell size: %d, Range: %.1f" % [cell_size, last_weapon_range])

func _update_cell_size() -> void:
	var current_range = player_data.get_stat("weapon_range")
	# Use range * 0.8 so weapons check ~3x3 = 9 cells maximum
	cell_size = max(current_range * 0.8, 256.0)
	
	# Rebuild hash if range changed significantly
	if abs(current_range - last_weapon_range) > (last_weapon_range * range_change_threshold):
		print("Range changed significantly: %.1f -> %.1f, rebuilding hash" % [last_weapon_range, current_range])
		_rebuild_hash()
		last_weapon_range = current_range

# ===== ENEMY REGISTRATION =====
func register_enemy(enemy: BaseEnemy) -> void:
	if enemy.bypass_spatial_hash:
		always_check_enemies.append(enemy)
		bypass_enemies += 1
	else:
		_add_to_spatial_hash(enemy)
		spatial_hash_enemies += 1
	
	total_enemies += 1
	enemy.connect("tree_exiting", Callable(self, "_on_enemy_destroyed").bind(enemy))

func _on_enemy_destroyed(enemy: BaseEnemy) -> void:
	unregister_enemy(enemy)

func unregister_enemy(enemy: BaseEnemy) -> void:
	if enemy.bypass_spatial_hash:
		always_check_enemies.erase(enemy)
		bypass_enemies -= 1
	else:
		_remove_from_spatial_hash(enemy)
		spatial_hash_enemies -= 1
	
	total_enemies -= 1

func update_enemy_position(enemy: BaseEnemy, old_pos: Vector2, new_pos: Vector2) -> void:
	if enemy.bypass_spatial_hash:
		return  # Teleporting enemies don't use spatial hash
	
	var old_cell = _position_to_cell_id(old_pos)
	var new_cell = _position_to_cell_id(new_pos)
	
	if old_cell != new_cell:
		_remove_from_cell(enemy, old_cell)
		_add_to_cell(enemy, new_cell)

# ===== SPATIAL HASH OPERATIONS =====
func _add_to_spatial_hash(enemy: BaseEnemy) -> void:
	var cell_id = _position_to_cell_id(enemy.global_position)
	_add_to_cell(enemy, cell_id)

func _remove_from_spatial_hash(enemy: BaseEnemy) -> void:
	var cell_id = _position_to_cell_id(enemy.global_position)
	_remove_from_cell(enemy, cell_id)

func _add_to_cell(enemy: BaseEnemy, cell_id: int) -> void:
	if not hash_table.has(cell_id):
		hash_table[cell_id] = []
	hash_table[cell_id].append(enemy)

func _remove_from_cell(enemy: BaseEnemy, cell_id: int) -> void:
	if hash_table.has(cell_id):
		hash_table[cell_id].erase(enemy)
		if hash_table[cell_id].is_empty():
			hash_table.erase(cell_id)

func _position_to_cell_id(pos: Vector2) -> int:
	var cell_x = int(pos.x / cell_size)
	var cell_y = int(pos.y / cell_size)
	return (cell_x << 16) | (cell_y & 0xFFFF)  # Bit-pack for unique ID

func _rebuild_hash() -> void:
	var all_spatial_enemies = []
	
	# Collect all enemies from current hash
	for cell in hash_table.values():
		all_spatial_enemies.append_array(cell)
	
	# Clear and rebuild
	hash_table.clear()
	for enemy in all_spatial_enemies:
		_add_to_spatial_hash(enemy)

# ===== PUBLIC TARGETING API =====
func find_nearest_enemy_in_range(weapon_pos: Vector2, range: float) -> BaseEnemy:
	_update_cell_size()  # Check if range changed
	
	var best_enemy: BaseEnemy = null
	var best_dist_sq = range * range
	
	# Check spatial hash (nearby enemies)
	var nearby_enemies = _get_enemies_in_radius(weapon_pos, range)
	for enemy in nearby_enemies:
		if not is_instance_valid(enemy):
			continue
			
		var dist_sq = weapon_pos.distance_squared_to(enemy.global_position)
		if dist_sq < best_dist_sq:
			best_dist_sq = dist_sq
			best_enemy = enemy
	
	# Always check teleporting enemies (they bypass spatial hash)
	for enemy in always_check_enemies:
		if not is_instance_valid(enemy):
			continue
			
		var dist_sq = weapon_pos.distance_squared_to(enemy.global_position)
		if dist_sq < best_dist_sq:
			best_dist_sq = dist_sq
			best_enemy = enemy
	
	return best_enemy

func _get_enemies_in_radius(center: Vector2, radius: float) -> Array[BaseEnemy]:
	var result: Array[BaseEnemy] = []
	
	# Calculate cells to check (3x3 grid around center)
	var center_cell_x = int(center.x / cell_size)
	var center_cell_y = int(center.y / cell_size)
	
	for dx in range(-1, 2):  # -1, 0, 1
		for dy in range(-1, 2):
			var cell_id = ((center_cell_x + dx) << 16) | ((center_cell_y + dy) & 0xFFFF)
			if hash_table.has(cell_id):
				result.append_array(hash_table[cell_id])
	
	return result

# ===== DEBUG INFO =====
func get_performance_stats() -> Dictionary:
	return {
		"total_enemies": total_enemies,
		"spatial_hash_enemies": spatial_hash_enemies,
		"bypass_enemies": bypass_enemies,
		"hash_cells_used": hash_table.size(),
		"cell_size": cell_size,
		"weapon_range": player_data.get_stat("weapon_range") if player_data else 0
	}

func print_stats() -> void:
	var stats = get_performance_stats()
	print("=== TargetingManager Stats ===")
	print("Total enemies: %d (Hash: %d, Bypass: %d)" % [stats.total_enemies, stats.spatial_hash_enemies, stats.bypass_enemies])
	print("Hash cells used: %d, Cell size: %.1f" % [stats.hash_cells_used, stats.cell_size])
	print("Current weapon range: %.1f" % stats.weapon_range)
