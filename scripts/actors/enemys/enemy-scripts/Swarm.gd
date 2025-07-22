# scripts/actors/enemys/enemy-scripts/Swarm.gd
extends Node2D
class_name Swarm

@export var mini_biter_scene: PackedScene = preload("res://scenes/actors/enemys/MiniBiter.tscn")
@export var spawn_radius: float = 80.0

var power_level: int = 1
var rarity: String = "common"
var min_level: int = 3
var max_level: int = 25
var enemy_type: String = "swarm"

var base_power_level: int = 10

var has_spawned: bool = false
var final_spawn_count: int = 0

signal swarm_spawned(enemies: Array)
signal swarm_finished

func _ready() -> void:
	_calculate_spawn_count()
	
	await get_tree().process_frame
	_spawn_mini_biters()
	
	call_deferred("queue_free")

func _calculate_spawn_count() -> void:
	final_spawn_count = power_level

func apply_tier_scaling(level: int) -> void:
	var tier_multiplier = _get_tier_multiplier(level)
	power_level = base_power_level * tier_multiplier

func _get_tier_multiplier(level: int) -> int:
	if level < 5: return 1
	elif level < 10: return 2
	elif level < 15: return 4
	elif level < 20: return 8
	else: return 16

func activate_swarm(pos: Vector2, power: int) -> void:
	global_position = pos
	power_level = power
	has_spawned = false
	
	_calculate_spawn_count()
	_spawn_mini_biters()
	
	await get_tree().process_frame
	_finish_swarm()

func reset_for_pool() -> void:
	power_level = base_power_level
	has_spawned = false
	final_spawn_count = 0

func _spawn_mini_biters() -> void:
	if has_spawned:
		return
	
	if not mini_biter_scene:
		push_error("Swarm: mini_biter_scene not set!")
		return
	
	has_spawned = true
	var spawned_enemies: Array = []
	
	for i in final_spawn_count:
		var mini_biter = mini_biter_scene.instantiate()
		
		var angle = randf() * TAU
		var distance = randf_range(0, spawn_radius)
		var spawn_offset = Vector2(cos(angle), sin(angle)) * distance
		
		mini_biter.global_position = global_position + spawn_offset
		mini_biter.power_level = 1
		
		get_tree().current_scene.add_child(mini_biter)
		spawned_enemies.append(mini_biter)
		
		mini_biter._apply_combat_scaling()
	
	emit_signal("swarm_spawned", spawned_enemies)

func _finish_swarm() -> void:
	emit_signal("swarm_finished")
	
	if not has_signal("swarm_finished") or get_signal_connection_list("swarm_finished").is_empty():
		queue_free()

func _spawn_and_destroy() -> void:
	_spawn_mini_biters()
	call_deferred("queue_free")

func get_enemy_type() -> String:
	return enemy_type

func get_spawn_value() -> int:
	return final_spawn_count

func get_power_level() -> int:
	return power_level

func get_min_level() -> int:
	return min_level

func get_max_level() -> int:
	return max_level

func get_rarity() -> String:
	return rarity
