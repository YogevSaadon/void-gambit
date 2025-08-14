# scripts/game/spawning/EnemyPool.gd
extends RefCounted
class_name EnemyPool

# ===== SIMPLIFIED FOR NEW SPAWNING SYSTEM =====
# This class is now much simpler since we don't need power budget calculations
# We only need to track which enemies can spawn at which levels

# ===== ENEMY DEFINITIONS =====
var normal_enemies = [
	{"scene": "res://scenes/actors/enemys/Biter.tscn", "min_level": 1, "enemy_type": "biter"},
	{"scene": "res://scenes/actors/enemys/Triangle.tscn", "min_level": 2, "enemy_type": "smart_ship"},
	{"scene": "res://scenes/actors/enemys/Rectangle.tscn", "min_level": 3, "enemy_type": "smart_ship"},
	{"scene": "res://scenes/actors/enemys/Tank.tscn", "min_level": 4, "enemy_type": "tank"},
	{"scene": "res://scenes/actors/enemys/Star.tscn", "min_level": 5, "enemy_type": "star"},
	{"scene": "res://scenes/actors/enemys/Diamond.tscn", "min_level": 7, "enemy_type": "diamond"},
	{"scene": "res://scenes/actors/enemys/MotherShip.tscn", "min_level": 10, "enemy_type": "mother_ship"},
]

var special_enemies = [
	{"scene": "res://scenes/actors/enemys/GoldShip.tscn", "min_level": 1, "enemy_type": "gold_ship"},
]

# Enemies NOT in pools (spawned by other means):
# - Swarm: Removed from game
# - MiniBiter: Spawned by Swarm (removed)
# - EnemyMissile: Spawned by Diamond attacks
# - ChildShip: Spawned by MotherShip attacks

var _loaded_normal_scenes: Array[PackedScene] = []
var _loaded_special_scenes: Array[PackedScene] = []

# ===== INITIALIZATION =====
func _init():
	_load_all_scenes()

func _load_all_scenes() -> void:
	"""Load all enemy scenes"""
	print("EnemyPool: Loading enemy scenes for simplified spawning...")
	
	# Load normal enemies
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

# ===== ENEMY FILTERING (Simplified) =====
func get_normal_enemies_for_level(level: int) -> Array:
	"""Get all normal enemies available at this level"""
	var available = []
	
	for enemy_def in normal_enemies:
		if level >= enemy_def.min_level:
			var scene = load(enemy_def.scene)
			if scene:
				available.append(scene)
	
	return available

func get_special_enemies_for_level(level: int) -> Array:
	"""Get special enemies (Golden Ship, etc.) for level"""
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
		"removed_enemies": ["Swarm", "MiniBiter", "EnemyMissile", "ChildShip"]
	}

func print_enemy_breakdown() -> void:
	"""Print all enemies with their minimum levels"""
	print("\n=== ENEMY POOL BREAKDOWN ===")
	print("Normal Enemies:")
	for enemy_def in normal_enemies:
		var scene_name = enemy_def.scene.get_file().get_basename()
		print("  %s: Min Level %d (Type: %s)" % [
			scene_name, enemy_def.min_level, enemy_def.enemy_type
		])
	
	print("Special Enemies:")
	for enemy_def in special_enemies:
		var scene_name = enemy_def.scene.get_file().get_basename()
		print("  %s: Min Level %d (Type: %s)" % [
			scene_name, enemy_def.min_level, enemy_def.enemy_type
		])
	
	print("Removed from Spawning:")
	var removed = ["Swarm", "MiniBiter", "EnemyMissile", "ChildShip"]
	for enemy_name in removed:
		print("  %s: No longer spawns via main system" % enemy_name)
	
	print("===============================\n")

func print_level_progression(start_level: int = 1, end_level: int = 15) -> void:
	"""Print which enemies are available at each level"""
	print("\n=== LEVEL PROGRESSION ===")
	for level in range(start_level, end_level + 1):
		var available_types = get_enemy_types_for_level(level)
		print("Level %d: %s" % [level, ", ".join(available_types)])
	print("==========================\n")
