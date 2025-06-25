# Complete Optimized ChainLaserBeamController.gd
extends Node2D
class_name ChainLaserBeamController

@export var tick_time : float = 0.05
@export var validation_interval : float = 0.1

var muzzle : Node2D
var damage : float
var crit   : float
var range  : float
var max_chain_len : int = 1

# runtime
var chain      : Array[Node] = []
var segments   : Array[Node] = []
var tick_accum : float = 0.0
var validation_timer : float = 0.0
var hit_this_tick : = {}

const SEGMENT_SCENE : PackedScene = preload("res://scenes/bullets/BeamSegment.tscn")
@onready var pd := get_tree().root.get_node("PlayerData")

func set_beam_stats(m: Node2D, first_target: Node,
					dmg: float, cr: float, rng: float, reflects_left: int) -> void:
	muzzle        = m
	damage        = dmg
	crit          = cr
	range         = rng
	max_chain_len = 1 + reflects_left
	validation_timer = validation_interval
	_reset_chain(first_target)

func _process(delta: float) -> void:
	if muzzle == null:
		_clear_segments()
		return

	# ← ALWAYS clean invalid enemies first
	_clean_invalid_enemies()

	# Only do expensive range validation on intervals
	validation_timer -= delta
	if validation_timer <= 0.0:
		validation_timer = validation_interval
		_prune_chain()

	_extend_chain()
	_update_visuals()

	if chain.is_empty():
		_clear_segments()
		return

	tick_accum += delta
	if tick_accum >= tick_time:
		tick_accum = 0.0
		hit_this_tick.clear()
		for e in chain:
			_apply_damage(e)

# ← NEW: Fast cleanup of freed enemies (no distance checks)
func _clean_invalid_enemies() -> void:
	var original_size = chain.size()
	chain = chain.filter(func(enemy): return is_instance_valid(enemy))
	
	# Shrink segments if enemies were removed
	if chain.size() < original_size:
		_shrink_segments_to(chain.size())

# ← OPTIMIZED: Use distance_squared to avoid sqrt() when possible
func _is_valid_enemy(e) -> bool:
	if not is_instance_valid(e):
		return false
	
	var distance_sq = muzzle.global_position.distance_squared_to(e.global_position)
	var range_sq = range * range
	return distance_sq < range_sq

func _prune_chain() -> void:
	for i in range(chain.size()):
		if not _is_valid_enemy(chain[i]):
			chain.resize(i)
			_shrink_segments_to(i)
			break

func _extend_chain() -> void:
	while chain.size() < max_chain_len:
		var tail: Node = null
		if not chain.is_empty():
			tail = chain.back()
		
		var nxt := _find_next_enemy_from(tail)
		if nxt == null: 
			break
		chain.append(nxt)
		var from_pos = tail.global_position if tail else muzzle.global_position
		_add_segment(from_pos, nxt.global_position)

# ← OPTIMIZED: Use distance_squared for finding next enemy
func _find_next_enemy_from(from_node: Node) -> Node:
	var origin : Vector2
	if from_node != null:
		origin = from_node.global_position
	else:
		origin = muzzle.global_position

	var best : Node = null
	var best_d_sq := range * range
	
	for e in get_tree().get_nodes_in_group("Enemies"):
		if not is_instance_valid(e) or e in chain:
			continue
		var d_sq = origin.distance_squared_to(e.global_position)
		if d_sq < best_d_sq:
			best_d_sq = d_sq
			best = e
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
		return
	hit_this_tick[enemy] = true
	if not enemy.has_method("apply_damage"):
		return

	var is_crit: bool = randf() < crit
	enemy.apply_damage(damage, is_crit)

# ── segment visual handling ─────────────────────────
func _add_segment(start: Vector2, end: Vector2) -> void:
	var seg = SEGMENT_SCENE.instantiate()
	add_child(seg)
	seg.update_segment(start, end)
	segments.append(seg)

func _update_visuals() -> void:
	if segments.is_empty(): 
		return
	if chain.is_empty():
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
		s.queue_free()
	segments.clear()
