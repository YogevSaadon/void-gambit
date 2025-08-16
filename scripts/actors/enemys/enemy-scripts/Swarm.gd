# scripts/actors/enemys/enemy-scripts/Swarm.gd
extends Node2D
class_name Swarm

# ===== FLEXIBLE SPAWNING CONFIGURATION =====
@export var spawn_radius: float = 80.0
@export var spawn_count: int = 5              # How many enemies to spawn
@export var enemy_scene_to_spawn: PackedScene = null  # What enemy type to spawn

# ===== AVAILABLE ENEMY SCENES (Can be configured) =====
var available_enemy_scenes = {
	"mini_biter": "res://scenes/actors/enemys/MiniBiter.tscn",
	"biter": "res://scenes/actors/enemys/Biter.tscn",
	"triangle": "res://scenes/actors/enemys/Triangle.tscn",
	"rectangle": "res://scenes/actors/enemys/Rectangle.tscn",
	"tank": "res://scenes/actors/enemys/Tank.tscn",
	"star": "res://scenes/actors/enemys/Star.tscn",
	"diamond": "res://scenes/actors/enemys/Diamond.tscn",
	"mother_ship": "res://scenes/actors/enemys/MotherShip.tscn"
}

# ===== RUNTIME STATE =====
var has_spawned: bool = false
var enemy_type_to_spawn: String = "mini_biter"  # Default to mini_biter for compatibility

# ===== METADATA =====
var enemy_type: String = "swarm"

# ===== SIGNALS =====
signal swarm_spawned(enemies: Array)
signal swarm_finished

# ===== LIFECYCLE =====
func _ready() -> void:
	# If no specific scene is set, use the default based on enemy_type_to_spawn
	if not enemy_scene_to_spawn:
		_load_enemy_scene_by_type(enemy_type_to_spawn)
	
	# Spawn immediately when ready
	await get_tree().process_frame
	_spawn_enemies()
	
	# Clean up after spawning
	call_deferred("queue_free")

# ===== MAIN SPAWNING METHOD =====
func _spawn_enemies() -> void:
	"""Spawn the configured number of the specified enemy type"""
	if has_spawned:
		return
	
	if not enemy_scene_to_spawn:
		push_error("Swarm: No enemy scene set for spawning!")
		return
	
	has_spawned = true
	var spawned_enemies: Array = []
	
	for i in spawn_count:
		var enemy = enemy_scene_to_spawn.instantiate()
		
		# Random position within spawn radius
		var angle = randf() * TAU
		var distance = randf_range(0, spawn_radius)
		var spawn_offset = Vector2(cos(angle), sin(angle)) * distance
		
		enemy.global_position = global_position + spawn_offset
		
		# Add to scene
		get_tree().current_scene.add_child(enemy)
		spawned_enemies.append(enemy)
		
		# Apply any post-spawn setup (tier scaling, etc.)
		if enemy.has_method("_apply_combat_scaling"):
			enemy._apply_combat_scaling()
	
	emit_signal("swarm_spawned", spawned_enemies)
	print("Swarm: Spawned %d %s enemies" % [spawn_count, enemy_type_to_spawn])

# ===== CONFIGURATION METHODS =====
func configure_swarm(enemy_type: String, count: int, position: Vector2 = Vector2.ZERO) -> void:
	"""Configure swarm before spawning"""
	enemy_type_to_spawn = enemy_type
	spawn_count = count
	
	if position != Vector2.ZERO:
		global_position = position
	
	_load_enemy_scene_by_type(enemy_type)

func configure_swarm_with_scene(scene: PackedScene, count: int, position: Vector2 = Vector2.ZERO) -> void:
	"""Configure swarm with a specific scene"""
	enemy_scene_to_spawn = scene
	spawn_count = count
	
	if position != Vector2.ZERO:
		global_position = position

func _load_enemy_scene_by_type(enemy_type: String) -> void:
	"""Load enemy scene based on type string"""
	if enemy_type in available_enemy_scenes:
		var scene_path = available_enemy_scenes[enemy_type]
		enemy_scene_to_spawn = load(scene_path)
		if not enemy_scene_to_spawn:
			push_error("Swarm: Failed to load enemy scene: " + scene_path)
	else:
		push_error("Swarm: Unknown enemy type: " + enemy_type)

# ===== STATIC FACTORY METHODS (For easy spawning) =====
static func spawn_mini_biter_swarm(position: Vector2, count: int = 5) -> Swarm:
	"""Create a swarm of mini biters at position"""
	var swarm_scene = load("res://scenes/actors/enemys/Swarm.tscn")
	var swarm = swarm_scene.instantiate()
	swarm.configure_swarm("mini_biter", count, position)
	return swarm

static func spawn_enemy_group(enemy_type: String, position: Vector2, count: int) -> Swarm:
	"""Create a swarm of any enemy type at position"""
	var swarm_scene = load("res://scenes/actors/enemys/Swarm.tscn")
	var swarm = swarm_scene.instantiate()
	swarm.configure_swarm(enemy_type, count, position)
	return swarm

# ===== COMPATIBILITY METHODS (For existing code) =====
func activate_swarm(pos: Vector2, power: int) -> void:
	"""Legacy method - now uses spawn_count instead of power"""
	global_position = pos
	spawn_count = max(1, power)  # Convert power to spawn count
	has_spawned = false
	
	_spawn_enemies()
	
	await get_tree().process_frame
	_finish_swarm()

func apply_tier_scaling(level: int) -> void:
	"""Legacy method - tier scaling now handled per enemy after spawn"""
	# Tier scaling is now applied individually to each spawned enemy
	pass

func reset_for_pool() -> void:
	"""Reset swarm for object pooling (if used)"""
	spawn_count = 5
	has_spawned = false
	enemy_type_to_spawn = "mini_biter"

func _finish_swarm() -> void:
	"""Finish swarm spawning"""
	emit_signal("swarm_finished")
	
	if not has_signal("swarm_finished") or get_signal_connection_list("swarm_finished").is_empty():
		queue_free()

# ===== PUBLIC INTERFACE =====
func get_enemy_type() -> String:
	return enemy_type

func get_spawn_value() -> int:
	return spawn_count

func get_configured_enemy_type() -> String:
	return enemy_type_to_spawn

# ===== DEBUG INFO =====
func get_swarm_info() -> Dictionary:
	return {
		"enemy_type_to_spawn": enemy_type_to_spawn,
		"spawn_count": spawn_count,
		"spawn_radius": spawn_radius,
		"has_spawned": has_spawned,
		"scene_loaded": enemy_scene_to_spawn != null
	}
