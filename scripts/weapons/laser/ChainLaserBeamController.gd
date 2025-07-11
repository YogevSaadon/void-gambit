# scripts/weapons/laser/ChainLaserBeamController.gd
extends Node2D
class_name ChainLaserBeamController

# ===== CHAIN LASER REFLECTION SYSTEM =====
# DOMAIN: Bullet hell visual beam weapons that chain between enemies
# CHALLENGE: Enemies die unpredictably, breaking visual chains mid-beam
# SOLUTION: Dynamic chain rebuilding with spatial optimization

@export var tick_time: float = 0.05
@export var validation_interval: float = 0.1

var muzzle: Node2D
var damage: float
var crit: float
var range: float
var max_chain_len: int = 1

# ===== CHAIN STATE MANAGEMENT =====
var chain: Array[Node] = []           # Current enemy chain
var segments: Array[Node] = []        # Visual beam segments
var tick_accum: float = 0.0
var validation_timer: float = 0.0
var hit_this_tick: Dictionary = {}    # Prevents double-damage per tick

const SEGMENT_SCENE: PackedScene = preload("res://scenes/weapons/laser/BeamSegment.tscn")
@onready var pd: PlayerData = get_tree().root.get_node("PlayerData")

func set_beam_stats(m: Node2D, first_target: Node, dmg: float, cr: float, rng: float, reflects_left: int) -> void:
	muzzle = m
	damage = dmg
	crit = cr
	range = rng
	max_chain_len = 1 + reflects_left
	validation_timer = validation_interval
	_reset_chain(first_target)

func _process(delta: float) -> void:
	if muzzle == null:
		_clear_segments()
		return

	_clean_invalid_enemies()

	# STAGGERED VALIDATION: Prevents frame spikes from simultaneous chain rebuilds
	validation_timer -= delta
	if validation_timer <= 0.0:
		validation_timer = validation_interval
		_prune_chain()

	_extend_chain()
	_update_visuals()

	if chain.is_empty():
		_clear_segments()
		return

	# DAMAGE TICK SYSTEM: Continuous damage while beam is active
	tick_accum += delta
	if tick_accum >= tick_time:
		tick_accum = 0.0
		hit_this_tick.clear()
		for e in chain:
			_apply_damage(e)

func _get_current_range() -> float:
	# DYNAMIC RANGE: Adapts to weapon upgrades in real-time
	if muzzle and is_instance_valid(muzzle.get_parent()):
		var weapon = muzzle.get_parent()
		if weapon is LaserWeapon and "final_range" in weapon:
			return weapon.final_range
	return range

# ===== CHAIN VALIDATION =====
func _clean_invalid_enemies() -> void:
	var original_size = chain.size()
	chain = chain.filter(func(enemy): return is_instance_valid(enemy))
	
	if chain.size() < original_size:
		_shrink_segments_to(chain.size())

func _is_valid_enemy(e: Node) -> bool:
	if not is_instance_valid(e):
		return false
	
	var current_range = _get_current_range()
	var distance_sq = muzzle.global_position.distance_squared_to(e.global_position)
	var range_sq = current_range * current_range
	return distance_sq < range_sq

func _prune_chain() -> void:
	# RANGE VALIDATION: Remove enemies that moved out of range
	for i in range(chain.size()):
		if not _is_valid_enemy(chain[i]):
			chain.resize(i)
			_shrink_segments_to(i)
			break

func _extend_chain() -> void:
	# CHAIN BUILDING: Extend to maximum reflection count
	while chain.size() < max_chain_len:
		var tail: Node = null
		if not chain.is_empty():
			tail = chain.back()
		
		var nxt = _find_next_enemy_from(tail)
		if nxt == null: 
			break
		chain.append(nxt)
		var from_pos = tail.global_position if tail else muzzle.global_position
		_add_segment(from_pos, nxt.global_position)

func _find_next_enemy_from(from_node: Node) -> Node:
	"""Find nearest enemy not already in laser chain"""
	var origin: Vector2
	if from_node != null:
		origin = from_node.global_position
	else:
		origin = muzzle.global_position

	var current_range = _get_current_range()

	var space_state = get_world_2d().direct_space_state
	var params = PhysicsShapeQueryParameters2D.new()
	
	var circle = CircleShape2D.new()
	circle.radius = current_range
	
	params.shape = circle
	params.transform = Transform2D(0, origin)
	params.collision_mask = 1 << 2  # Enemy layer
	params.collide_with_areas = true
	params.collide_with_bodies = false
	
	# Spatial query returns max 32 nearby enemies
	var results = space_state.intersect_shape(params, 32)
	
	# Find closest in small result set (O(32), not O(all_enemies))
	var best: Node = null
	var best_d_sq: float = current_range * current_range
	
	for result in results:
		var enemy = result.collider
		if not is_instance_valid(enemy) or enemy in chain:
			continue  # Skip invalid or already-chained enemies
		var d_sq = origin.distance_squared_to(enemy.global_position)
		if d_sq < best_d_sq:
			best_d_sq = d_sq
			best = enemy
	
	return best

func _reset_chain(first_target: Node) -> void:
	_clear_segments()
	chain.clear()
	if is_instance_valid(first_target):
		chain.append(first_target)
		_add_segment(muzzle.global_position, first_target.global_position)

func _apply_damage(enemy: Node) -> void:
	if not is_instance_valid(enemy):
		return
	if enemy in hit_this_tick: 
		return  # Prevent double-damage in single tick
	hit_this_tick[enemy] = true
	if not enemy.has_method("apply_damage"):
		return

	var is_crit: bool = randf() < crit
	enemy.apply_damage(damage, is_crit)

# ===== VISUAL MANAGEMENT =====
func _add_segment(start: Vector2, end: Vector2) -> void:
	var seg = SEGMENT_SCENE.instantiate()
	add_child(seg)
	seg.update_segment(start, end)
	segments.append(seg)

func _update_visuals() -> void:
	if segments.is_empty() or chain.is_empty():
		return
	
	segments[0].update_segment(muzzle.global_position, chain[0].global_position)
	for i in range(1, chain.size()):
		if i < segments.size():
			segments[i].update_segment(chain[i-1].global_position, chain[i].global_position)

func _shrink_segments_to(count: int) -> void:
	while segments.size() > count:
		segments.back().queue_free()
		segments.pop_back()

func _clear_segments() -> void:
	for s in segments:
		if is_instance_valid(s):
			var parent = s.get_parent()
			if parent:
				parent.remove_child(s)
			s.queue_free()
	segments.clear()

func _exit_tree() -> void:
	_clear_segments()
	chain.clear()
	hit_this_tick.clear()
