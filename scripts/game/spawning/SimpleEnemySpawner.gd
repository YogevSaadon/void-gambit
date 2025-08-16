# scripts/game/spawning/SimpleEnemySpawner.gd
extends RefCounted
class_name SimpleEnemySpawner

# ===== ENEMY DEFINITIONS =====
# Only enemies that should spawn in the main rotation
var normal_enemies = [
	{"scene": "res://scenes/actors/enemys/Biter.tscn", "min_level": 1},
	{"scene": "res://scenes/actors/enemys/MiniBiter.tscn", "min_level": 1},  # ← ADDED: Now spawns normally
	{"scene": "res://scenes/actors/enemys/Triangle.tscn", "min_level": 2},
	{"scene": "res://scenes/actors/enemys/Rectangle.tscn", "min_level": 3},
	{"scene": "res://scenes/actors/enemys/Tank.tscn", "min_level": 4},
	{"scene": "res://scenes/actors/enemys/Star.tscn", "min_level": 5},
	{"scene": "res://scenes/actors/enemys/Diamond.tscn", "min_level": 7},
	{"scene": "res://scenes/actors/enemys/MotherShip.tscn", "min_level": 10},
]

# Enemies NOT in main spawn rotation:
# - Swarm: Available for special group spawning (future use)
# - EnemyMissile: Only spawned by Diamond attacks
# - GoldShip: Spawned separately by GoldenShipSpawner
# - ChildShip: Only spawned by MotherShip attacks

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
	Generate spawn list: Each available enemy spawns 'level' times
	Level 1: 1 Biter + 1 MiniBiter
	Level 2: 2 Biter + 2 MiniBiter + 2 Triangle
	Level N: N of each available enemy
	"""
	var spawn_list: Array[PackedScene] = []
	
	# Get enemies available at this level
	var available_enemies = _get_available_enemies_for_level(level)
	
	# For each available enemy, add it 'level' times
	for enemy_def in available_enemies:
		var scene = _loaded_scenes.get(enemy_def.scene)
		if scene:
			for i in level:  # Spawn 'level' times
				spawn_list.append(scene)
	
	print("SimpleSpawner Level %d: %d total enemies (%d types × %d copies each)" % [
		level, spawn_list.size(), available_enemies.size(), level
	])
	
	return spawn_list

func _get_available_enemies_for_level(level: int) -> Array:
	"""Get all enemy types that can spawn at this level (including MiniBiter)"""
	var available = []
	
	for enemy_def in normal_enemies:
		if level >= enemy_def.min_level:
			available.append(enemy_def)
	
	return available

func get_enemies_count_for_level(level: int) -> int:
	"""Get total number of enemies that will spawn per batch at this level"""
	var available_types = _get_available_enemies_for_level(level)
	return available_types.size() * level

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
		"enemy_types": get_enemy_types_for_level(level),
		"swarm_available_for_future": true
	}

func print_level_breakdown(start_level: int = 1, end_level: int = 15) -> void:
	"""Print spawning breakdown for multiple levels"""
	print("\n=== SIMPLE SPAWNING BREAKDOWN ===")
	for level in range(start_level, end_level + 1):
		var stats = get_spawner_statistics(level)
		print("Level %d: %d enemies (%d types × %d copies) - Types: %s" % [
			level,
			stats.total_enemies_per_batch,
			stats.available_enemy_types,
			stats.copies_per_enemy,
			", ".join(stats.enemy_types)
		])
	print("===================================\n")
