# REPLACE your SimpleEnemySpawner.gd with this fixed version:

# scripts/game/spawning/SimpleEnemySpawner.gd
extends RefCounted
class_name SimpleEnemySpawner

# ===== ENEMY DEFINITIONS =====
# Only enemies that should spawn in the main rotation
var normal_enemies = [
	{"scene": "res://scenes/actors/enemys/Biter.tscn", "min_level": 1, "max_level": 999},
	{"scene": "res://scenes/actors/enemys/MiniBiter.tscn", "min_level": 1, "max_level": 999},
	{"scene": "res://scenes/actors/enemys/Triangle.tscn", "min_level": 2, "max_level": 999},
	{"scene": "res://scenes/actors/enemys/Rectangle.tscn", "min_level": 3, "max_level": 999},
	{"scene": "res://scenes/actors/enemys/Tank.tscn", "min_level": 4, "max_level": 999},
	{"scene": "res://scenes/actors/enemys/Star.tscn", "min_level": 5, "max_level": 999},
	{"scene": "res://scenes/actors/enemys/Diamond.tscn", "min_level": 7, "max_level": 999},
	{"scene": "res://scenes/actors/enemys/MotherShip.tscn", "min_level": 10, "max_level": 999},
]

var _loaded_scenes: Dictionary = {}

func _init():
	_preload_enemy_scenes()

func _preload_enemy_scenes() -> void:
	"""Preload all enemy scenes for performance"""
	for enemy_def in normal_enemies:
		var scene = load(enemy_def.scene)
		if scene:
			_loaded_scenes[enemy_def.scene] = scene
		else:
			push_error("SimpleEnemySpawner: Failed to load scene: " + enemy_def.scene)

func generate_simple_spawn_list(level: int) -> Array[PackedScene]:
	"""
	FIXED: Generate spawn list: Each available enemy spawns 'level' times
	Level 1: 1 Biter + 1 MiniBiter = 2 total
	Level 2: 2 Biter + 2 MiniBiter + 2 Triangle = 6 total  
	Level 25: 25 of each available enemy = 25 * 8 = 200 total
	"""
	var spawn_list: Array[PackedScene] = []
	
	# Get enemies available at this level
	var available_enemies = _get_available_enemies_for_level(level)
	
	print("Level %d: %d available enemy types" % [level, available_enemies.size()])
	
	# For each available enemy, add it 'level' times
	for enemy_def in available_enemies:
		var scene = _loaded_scenes.get(enemy_def.scene)
		if scene:
			var enemy_name = enemy_def.scene.get_file().get_basename()
			print("  Adding %d copies of %s" % [level, enemy_name])
			
			for i in level:  # Spawn 'level' times
				spawn_list.append(scene)
		else:
			push_error("Failed to get scene for: " + enemy_def.scene)
	
	print("Generated %d total enemies for level %d" % [spawn_list.size(), level])
	
	return spawn_list

func _get_available_enemies_for_level(level: int) -> Array:
	"""FIXED: Get all enemy types that can spawn at this level"""
	var available = []
	
	for enemy_def in normal_enemies:
		var min_level = enemy_def.get("min_level", 1)
		var max_level = enemy_def.get("max_level", 999)
		
		if level >= min_level and level <= max_level:
			available.append(enemy_def)
			
	return available

func get_enemies_count_for_level(level: int) -> int:
	"""Get total number of enemies that will spawn per batch at this level"""
	var available_types = _get_available_enemies_for_level(level)
	var total = available_types.size() * level
	
	print("Level %d will spawn %d enemies per batch (%d types × %d copies)" % [
		level, total, available_types.size(), level
	])
	
	return total

func get_enemy_types_for_level(level: int) -> Array[String]:
	"""Get list of enemy type names for this level (for debugging)"""
	var available = _get_available_enemies_for_level(level)
	var type_names: Array[String] = []
	
	for enemy_def in available:
		var scene_name = enemy_def.scene.get_file().get_basename()
		type_names.append(scene_name)
	
	return type_names

# ===== DEBUG INFO =====
func get_spawner_statistics(level: int) -> Dictionary:
	"""Get comprehensive statistics about spawning for given level"""
	var available_enemies = _get_available_enemies_for_level(level)
	
	return {
		"level": level,
		"available_enemy_types": available_enemies.size(),
		"copies_per_enemy": level,
		"total_enemies_per_batch": get_enemies_count_for_level(level),
		"enemy_types": get_enemy_types_for_level(level)
	}

func print_level_breakdown(start_level: int = 1, end_level: int = 25) -> void:
	"""Print spawning breakdown for multiple levels"""
	for level in range(start_level, end_level + 1):
		var stats = get_spawner_statistics(level)
