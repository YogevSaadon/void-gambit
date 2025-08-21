# scripts/game/spawning/EnemyPool.gd
extends RefCounted
class_name EnemyPool

# ===== ENEMY DEFINITIONS =====
var normal_enemies = [
	{"scene": "res://scenes/actors/enemys/Biter.tscn", "min_level": 1, "enemy_type": "biter"},
	{"scene": "res://scenes/actors/enemys/MiniBiter.tscn", "min_level": 1, "enemy_type": "mini_biter"},  # ← ADDED
	{"scene": "res://scenes/actors/enemys/Triangle.tscn", "min_level": 2, "enemy_type": "smart_ship"},
	{"scene": "res://scenes/actors/enemys/Rectangle.tscn", "min_level": 3, "enemy_type": "smart_ship"},
	{"scene": "res://scenes/actors/enemys/Tank.tscn", "min_level": 4, "enemy_type": "tank"},
	{"scene": "res://scenes/actors/enemys/Star.tscn", "min_level": 5, "enemy_type": "star"},
	{"scene": "res://scenes/actors/enemys/Diamond.tscn", "min_level": 7, "enemy_type": "diamond"},
	{"scene": "res://scenes/actors/enemys/MotherShip.tscn", "min_level": 10, "enemy_type": "mother_ship"},
]

var special_enemies = [
	{"scene": "res://scenes/actors/enemys/GoldShip.tscn", "min_level": 1, "enemy_type": "gold_ship"},
	{"scene": "res://scenes/actors/enemys/Swarm.tscn", "min_level": 1, "enemy_type": "swarm"},  # ← ADDED for future use
]

# Enemies NOT in normal pools (spawned by other means):
# - EnemyMissile: Spawned by Diamond attacks
# - ChildShip: Spawned by MotherShip attacks

var _loaded_normal_scenes: Array[PackedScene] = []
var _loaded_special_scenes: Array[PackedScene] = []

# ===== INITIALIZATION =====
func _init():
	_load_all_scenes()

func _load_all_scenes() -> void:
	"""Load all enemy scenes"""
	print("EnemyPool: Loading enemy scenes...")
	
	# Load normal enemies (including MiniBiter now)
	for enemy_def in normal_enemies:
		var scene = load(enemy_def.scene)
		if scene:
			_loaded_normal_scenes.append(scene)
		else:
			push_error("EnemyPool: Failed to load normal enemy: " + enemy_def.scene)
	
	# Load special enemies  
	for enemy_def in special_enemies:
		var scene = load(enemy_def.scene)
		if scene:
			_loaded_special_scenes.append(scene)
		else:
			push_error("EnemyPool: Failed to load special enemy: " + enemy_def.scene)
	
	print("EnemyPool: Loaded %d normal enemies, %d special enemies" % [
		_loaded_normal_scenes.size(), _loaded_special_scenes.size()
	])

# ===== ENEMY FILTERING =====
func get_normal_enemies_for_level(level: int) -> Array:
	"""Get all normal enemies available at this level (including MiniBiter)"""
	var available = []
	
	for enemy_def in normal_enemies:
		if level >= enemy_def.min_level:
			var scene = load(enemy_def.scene)
			if scene:
				available.append(scene)
	
	return available

func get_special_enemies_for_level(level: int) -> Array:
	"""Get special enemies for level (includes Swarm for future use)"""
	var available = []
	
	for enemy_def in special_enemies:
		if level >= enemy_def.min_level:
			var scene = load(enemy_def.scene)
			if scene:
				available.append(scene)
	
	return available

# ===== LEVEL INFO =====
func get_enemy_types_for_level(level: int) -> Array[String]:
	"""Get list of enemy type names available at this level"""
	var types: Array[String] = []
	
	for enemy_def in normal_enemies:
		if level >= enemy_def.min_level:
			types.append(enemy_def.enemy_type)
	
	return types

func get_enemy_count_for_level(level: int) -> int:
	"""Get number of different enemy types available at this level"""
	var count = 0
	
	for enemy_def in normal_enemies:
		if level >= enemy_def.min_level:
			count += 1
	
	return count

# ===== DEBUG INFO =====
func get_pool_statistics() -> Dictionary:
	"""Get statistics about the enemy pool"""
	return {
		"total_normal_enemies": normal_enemies.size(),
		"total_special_enemies": special_enemies.size(),
		"loaded_normal_scenes": _loaded_normal_scenes.size(),
		"loaded_special_scenes": _loaded_special_scenes.size(),
		"swarm_available_for_future": true
	}

func print_enemy_breakdown() -> void:
	"""Print all enemies with their minimum levels"""
	for enemy_def in normal_enemies:
		var scene_name = enemy_def.scene.get_file().get_basename()
	
	for enemy_def in special_enemies:
		var scene_name = enemy_def.scene.get_file().get_basename()
	
	var removed = ["EnemyMissile", "ChildShip"]

func print_level_progression(start_level: int = 1, end_level: int = 15) -> void:
	"""Print which enemies are available at each level"""
	for level in range(start_level, end_level + 1):
		var available_types = get_enemy_types_for_level(level)
