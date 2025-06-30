# scripts/actors/enemys/swarm/Swarm.gd
extends Node2D  # Changed from Node2D to Area2D
class_name Swarm

# ===== SWARM CONFIGURATION =====
@export var mini_biter_scene: PackedScene = preload("res://scenes/actors/enemys/MiniBiter.tscn")
@export var spawn_count: int = 10          # Now spawns 10 mini-biters
@export var spawn_radius: float = 80.0

# ===== RUNTIME STATE =====
var power_level: int = 1
var has_spawned: bool = false

# ===== OBJECT POOL FRIENDLY APPROACH =====
signal swarm_spawned(enemies: Array)  # For potential pool management
signal swarm_finished  # For pool to know when to reclaim this node

func _ready() -> void:
	# Wait one frame for Level.gd to set our position, then spawn mini-biters
	await get_tree().process_frame
	_spawn_mini_biters()
	
	# Self-destruct after spawning
	call_deferred("queue_free")

# ===== POOL INTERFACE =====
func activate_swarm(pos: Vector2, power: int) -> void:
	"""Called by object pool or wave manager to activate this swarm"""
	global_position = pos
	power_level = power
	has_spawned = false
	
	# Spawn immediately
	_spawn_mini_biters()
	
	# Return to pool after a short delay (let spawning complete)
	await get_tree().process_frame
	_finish_swarm()

func reset_for_pool() -> void:
	"""Called by object pool when reclaiming this node"""
	power_level = 1
	has_spawned = false
	# Clear any other state if needed

# ===== SPAWNING LOGIC =====
func _spawn_mini_biters() -> void:
	if has_spawned:
		return  # Prevent double-spawning
	
	if not mini_biter_scene:
		push_error("Swarm: mini_biter_scene not set!")
		return
	
	has_spawned = true
	var spawned_enemies: Array = []
	
	# POWER LEVEL DIVISION: Total swarm power divided among mini-biters
	var mini_power_level = max(1, power_level / spawn_count)  # Divide power among mini-biters
	
	for i in spawn_count:
		var mini_biter = mini_biter_scene.instantiate()
		
		# Set position in very tight cluster around spawn point
		var angle = randf() * TAU  # Completely random angle
		var distance = randf_range(0, spawn_radius)  # From center to edge (0-15 pixels)
		var spawn_offset = Vector2(cos(angle), sin(angle)) * distance
		
		mini_biter.global_position = global_position + spawn_offset
		mini_biter.power_level = mini_power_level  # Each gets divided power
		
		# Add to current scene
		get_tree().current_scene.add_child(mini_biter)
		spawned_enemies.append(mini_biter)
		
		# Apply power scaling after adding to scene
		mini_biter._apply_power_scale()
	
	# Emit signal for potential pool tracking
	emit_signal("swarm_spawned", spawned_enemies)
	
	print("Swarm spawned %d mini-biters, each at power level %d (total: %d)" % [spawn_count, mini_power_level, power_level])

func _finish_swarm() -> void:
	"""Signal that this swarm is done and can be returned to pool"""
	emit_signal("swarm_finished")
	
	# If no pool system exists yet, just self-destruct
	if not has_signal("swarm_finished") or get_signal_connection_list("swarm_finished").is_empty():
		queue_free()

# ===== LEGACY SUPPORT (for current non-pooled system) =====
func _spawn_and_destroy() -> void:
	"""Legacy method for current system - spawns and self-destructs"""
	_spawn_mini_biters()
	call_deferred("queue_free")

# ===== METADATA =====
func get_enemy_type() -> String:
	return "swarm_spawner"

func get_spawn_value() -> int:
	return spawn_count * power_level
