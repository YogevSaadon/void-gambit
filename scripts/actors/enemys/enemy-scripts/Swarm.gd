# scripts/actors/enemys/enemy-scripts/Swarm.gd
extends Node2D
class_name Swarm

# ===== SWARM CONFIGURATION =====
@export var mini_biter_scene: PackedScene = preload("res://scenes/actors/enemys/MiniBiter.tscn")
@export var spawn_radius: float = 80.0

# ===== ENEMY METADATA (Like other enemies) =====
var power_level: int = 1
var rarity: String = "common"
var min_level: int = 3          # NEW: First appears at level 3
var max_level: int = 25         # NEW: Can appear until level 25
var enemy_type: String = "swarm"

# ===== BASE STATS (Before tier scaling) =====
var base_power_level: int = 10  # NEW: Base power before tier upgrades

# ===== RUNTIME STATE =====
var has_spawned: bool = false
var final_spawn_count: int = 0  # NEW: Calculated spawn count

# ===== SIGNALS =====
signal swarm_spawned(enemies: Array)
signal swarm_finished

func _ready() -> void:
	# Calculate final spawn count based on power level
	_calculate_spawn_count()
	
	# Wait one frame for Level.gd to set our position, then spawn mini-biters
	await get_tree().process_frame
	_spawn_mini_biters()
	
	# Self-destruct after spawning
	call_deferred("queue_free")

# ===== NEW: POWER-BASED SPAWN CALCULATION =====
func _calculate_spawn_count() -> void:
	"""Calculate how many MiniBiters to spawn based on power level"""
	# Each MiniBiter has power level 1, so spawn count = our power level
	final_spawn_count = power_level
	
	print("Swarm (power %d): Will spawn %d MiniBiters" % [power_level, final_spawn_count])

# ===== NEW: TIER UPGRADE SYSTEM =====
func apply_tier_scaling(level: int) -> void:
	"""Apply tier-based power scaling like other enemies"""
	var tier_multiplier = _get_tier_multiplier(level)
	power_level = base_power_level * tier_multiplier
	
	print("Swarm at level %d: base_power=%d, tier_multiplier=%dx, final_power=%d" % [
		level, base_power_level, tier_multiplier, power_level
	])

func _get_tier_multiplier(level: int) -> int:
	"""Get tier multiplier based on level (matches other enemies)"""
	if level < 5:   return 1   # White tier
	elif level < 10: return 2  # Green tier  
	elif level < 15: return 4  # Blue tier
	elif level < 20: return 8  # Purple tier
	else: return 16            # Orange tier

# ===== POOL INTERFACE (Unchanged) =====
func activate_swarm(pos: Vector2, power: int) -> void:
	"""Called by object pool or wave manager to activate this swarm"""
	global_position = pos
	power_level = power
	has_spawned = false
	
	# Calculate spawn count and spawn immediately
	_calculate_spawn_count()
	_spawn_mini_biters()
	
	# Return to pool after a short delay
	await get_tree().process_frame
	_finish_swarm()

func reset_for_pool() -> void:
	"""Called by object pool when reclaiming this node"""
	power_level = base_power_level
	has_spawned = false
	final_spawn_count = 0

# ===== SPAWNING LOGIC (Updated) =====
func _spawn_mini_biters() -> void:
	if has_spawned:
		return
	
	if not mini_biter_scene:
		push_error("Swarm: mini_biter_scene not set!")
		return
	
	has_spawned = true
	var spawned_enemies: Array = []
	
	print("Swarm: Spawning %d MiniBiters (power level %d)" % [final_spawn_count, power_level])
	
	for i in final_spawn_count:
		var mini_biter = mini_biter_scene.instantiate()
		
		# Set position in tight cluster around spawn point
		var angle = randf() * TAU
		var distance = randf_range(0, spawn_radius)
		var spawn_offset = Vector2(cos(angle), sin(angle)) * distance
		
		mini_biter.global_position = global_position + spawn_offset
		mini_biter.power_level = 1  # MiniBiters always stay power level 1
		
		# Add to current scene
		get_tree().current_scene.add_child(mini_biter)
		spawned_enemies.append(mini_biter)
		
		# Apply power scaling after adding to scene
		mini_biter._apply_power_scale()
	
	# Emit signal for potential pool tracking
	emit_signal("swarm_spawned", spawned_enemies)
	
	print("Swarm: Successfully spawned %d MiniBiters" % final_spawn_count)

func _finish_swarm() -> void:
	"""Signal that this swarm is done and can be returned to pool"""
	emit_signal("swarm_finished")
	
	# If no pool system exists yet, just self-destruct
	if not has_signal("swarm_finished") or get_signal_connection_list("swarm_finished").is_empty():
		queue_free()

# ===== LEGACY SUPPORT =====
func _spawn_and_destroy() -> void:
	"""Legacy method for current system - spawns and self-destructs"""
	_spawn_mini_biters()
	call_deferred("queue_free")

# ===== METADATA (For spawn system) =====
func get_enemy_type() -> String:
	return enemy_type

func get_spawn_value() -> int:
	"""Returns total 'value' this swarm represents"""
	return final_spawn_count  # Each MiniBiter = 1 value

func get_power_level() -> int:
	return power_level

func get_min_level() -> int:
	return min_level

func get_max_level() -> int:
	return max_level

func get_rarity() -> String:
	return rarity
