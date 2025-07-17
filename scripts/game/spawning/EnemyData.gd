# scripts/game/spawning/EnemyData.gd
extends RefCounted
class_name EnemyData

## Data wrapper for enemy information with tier scaling
## Stores enemy scene, power levels, constraints, and handles scaling

# ===== ENEMY METADATA =====
var scene: PackedScene              # Enemy scene to instantiate
var base_power_level: int           # Base power before tier scaling  
var scaled_power_level: int         # Final power after tier scaling
var min_level: int                  # Minimum level to appear
var max_level: int                  # Maximum level to appear
var enemy_type: String              # Type identifier
var rarity: String                  # Rarity tier
var is_special: bool = false        # Special spawning rules (Golden Ship, etc.)

# ===== INITIALIZATION =====
func _init(
	enemy_scene: PackedScene,
	base_power: int,
	minimum_level: int = 1,
	maximum_level: int = 25,
	type: String = "unknown",
	enemy_rarity: String = "common",
	special: bool = false
):
	scene = enemy_scene
	base_power_level = base_power
	scaled_power_level = base_power  # Will be updated by apply_tier_scaling()
	min_level = minimum_level
	max_level = maximum_level
	enemy_type = type
	rarity = enemy_rarity
	is_special = special

# ===== TIER SCALING =====
func apply_tier_scaling(tier_multiplier: int) -> void:
	"""Apply tier-based power scaling"""
	scaled_power_level = base_power_level * tier_multiplier
	
func get_scaled_power() -> int:
	"""Get current scaled power level"""
	return scaled_power_level

func get_base_power() -> int:
	"""Get base power level (before scaling)"""
	return base_power_level

# ===== LEVEL CONSTRAINTS =====
func can_spawn_at_level(level: int) -> bool:
	"""Check if this enemy can spawn at the given level"""
	return level >= min_level and level <= max_level

func is_available_for_spawning() -> bool:
	"""Check if this enemy should be included in normal spawning"""
	return not is_special

# ===== UTILITY METHODS =====
func get_scene_path() -> String:
	"""Get resource path for debugging"""
	return scene.resource_path if scene else "null"

func get_scene_name() -> String:
	"""Get friendly scene name for debugging"""
	var path = get_scene_path()
	return path.get_file().get_basename() if path != "null" else "unknown"

# ===== DEBUG INFO =====
func to_debug_string() -> String:
	"""String representation for debugging"""
	return "%s (base:%d, scaled:%d, min_lvl:%d, type:%s)" % [
		get_scene_name(), base_power_level, scaled_power_level, min_level, enemy_type
	]

func get_debug_info() -> Dictionary:
	"""Get detailed debug information"""
	return {
		"scene_name": get_scene_name(),
		"scene_path": get_scene_path(),
		"base_power": base_power_level,
		"scaled_power": scaled_power_level,
		"min_level": min_level,
		"max_level": max_level,
		"enemy_type": enemy_type,
		"rarity": rarity,
		"is_special": is_special
	}

# ===== COMPARISON METHODS =====
func fits_in_budget(remaining_budget: int) -> bool:
	"""Check if this enemy fits in the remaining power budget"""
	return scaled_power_level <= remaining_budget

func is_exact_fit(budget: int) -> bool:
	"""Check if this enemy exactly matches the budget"""
	return scaled_power_level == budget

# ===== STATIC FACTORY METHODS =====
static func create_from_enemy_scene(enemy_scene: PackedScene) -> EnemyData:
	"""Create EnemyData by reading metadata from enemy scene"""
	var enemy_instance = enemy_scene.instantiate()
	
	# Read enemy metadata (assumes enemy has these properties)
	var base_power = enemy_instance.power_level if "power_level" in enemy_instance else 1
	var min_lvl = enemy_instance.min_level if "min_level" in enemy_instance else 1
	var max_lvl = enemy_instance.max_level if "max_level" in enemy_instance else 25
	var type = enemy_instance.enemy_type if "enemy_type" in enemy_instance else "unknown"
	var enemy_rarity = enemy_instance.rarity if "rarity" in enemy_instance else "common"
	
	# Check if this is a special enemy
	var special = _is_special_enemy(type)
	
	# Clean up the instance
	enemy_instance.queue_free()
	
	return EnemyData.new(enemy_scene, base_power, min_lvl, max_lvl, type, enemy_rarity, special)

static func _is_special_enemy(enemy_type: String) -> bool:
	"""Determine if enemy type has special spawning rules"""
	var special_types = ["gold_ship", "missile", "child_ship", "mini_biter"]
	return enemy_type in special_types
