# scripts/weapons/spawners/TargetSelector.gd
extends Node2D
class_name TargetSelector

# ===== TARGETING CONFIGURATION =====
@export var target_search_range: float = 350.0
@export var target_switch_interval: float = 2.0  # How often to pick new targets
@export var target_switch_variance: float = 1.0  # ±1 second randomness

# ===== TARGETING STATE =====
var owner_ship: MiniShip = null
var current_target: Node = null
var target_switch_timer: float = 0.0
var search_timer: float = 0.0

# ===== PERFORMANCE OPTIMIZATION =====
const SEARCH_INTERVAL: float = 0.2  # Search for targets every 0.2 seconds

# ===== INITIALIZATION =====
func initialize(ship: MiniShip) -> void:
	owner_ship = ship
	# Randomize initial timers to prevent sync
	target_switch_timer = randf_range(0.5, target_switch_interval)
	search_timer = randf() * SEARCH_INTERVAL

# ===== TARGETING UPDATE =====
func update_targeting(delta: float) -> void:
	if not owner_ship:
		return
	
	# Validate current target
	_validate_current_target()
	
	# Search for targets periodically
	search_timer -= delta
	if search_timer <= 0.0:
		search_timer = SEARCH_INTERVAL
		_search_for_targets()
	
	# Switch targets periodically for variety
	target_switch_timer -= delta
	if target_switch_timer <= 0.0:
		_switch_to_new_target()
		_reset_switch_timer()

func _validate_current_target() -> void:
	"""Remove invalid or dead targets"""
	if not current_target or not is_instance_valid(current_target):
		current_target = null
		return
	
	# Check if target is too far
	var distance = owner_ship.global_position.distance_to(current_target.global_position)
	if distance > target_search_range * 1.2:  # 20% buffer before dropping
		current_target = null
		return
	
	# Check if target is dead
	if current_target.has_method("get_actor_stats"):
		var stats = current_target.get_actor_stats()
		if stats.get("hp", 0) <= 0:
			current_target = null

func _search_for_targets() -> void:
	"""Find available enemies in range"""
	if not owner_ship:
		return
	
	# If no current target, find one immediately
	if not current_target:
		current_target = _find_best_target()

func _switch_to_new_target() -> void:
	"""Actively switch to a different target for variety"""
	var new_target = _find_best_target(current_target)  # Exclude current target
	if new_target:
		current_target = new_target

func _find_best_target(exclude_target: Node = null) -> Node:
	"""Find the best enemy target, optionally excluding one"""
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsShapeQueryParameters2D.new()
	
	var circle = CircleShape2D.new()
	circle.radius = target_search_range
	
	params.shape = circle
	params.transform = Transform2D(0, owner_ship.global_position)
	params.collision_mask = CollisionLayers.get_enemy_layer()
	params.collide_with_areas = true
	params.collide_with_bodies = false
	
	var results = space_state.intersect_shape(params, 32)
	
	# Collect valid targets
	var valid_targets: Array[Node] = []
	for result in results:
		var enemy = result.collider
		if _is_valid_target(enemy) and enemy != exclude_target:
			valid_targets.append(enemy)
	
	if valid_targets.is_empty():
		return null
	
	# Pick closest target (or add more sophisticated logic here)
	var best_target = null
	var best_dist_sq = target_search_range * target_search_range
	
	for target in valid_targets:
		var dist_sq = owner_ship.global_position.distance_squared_to(target.global_position)
		if dist_sq < best_dist_sq:
			best_dist_sq = dist_sq
			best_target = target
	
	return best_target

func _is_valid_target(enemy: Node) -> bool:
	"""Check if an enemy is a valid target"""
	if not enemy or not is_instance_valid(enemy):
		return false
	
	if not enemy.is_in_group("Enemies"):
		return false
	
	# Check if alive
	if enemy.has_method("get_actor_stats"):
		var stats = enemy.get_actor_stats()
		if stats.get("hp", 0) <= 0:
			return false
	
	return true

func _reset_switch_timer() -> void:
	"""Reset switch timer with variance for natural behavior"""
	var variance = randf_range(-target_switch_variance, target_switch_variance)
	target_switch_timer = target_switch_interval + variance

# ===== PUBLIC INTERFACE =====
func get_current_target() -> Node:
	"""Get the current target for movement and weapons"""
	return current_target

func force_target_switch() -> void:
	"""Force an immediate target switch"""
	_switch_to_new_target()
	_reset_switch_timer()

func has_target() -> bool:
	"""Check if we have a valid target"""
	return current_target != null and is_instance_valid(current_target)

# ===== DEBUG INFO =====
func get_debug_info() -> Dictionary:
	return {
		"current_target": current_target.name if current_target else "None",
		"switch_timer": "%.1fs" % target_switch_timer,
		"search_range": target_search_range,
		"has_valid_target": has_target()
	}
