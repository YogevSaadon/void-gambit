extends Node2D
class_name ChainLaserBeamController

@export var tick_time : float = 0.05          # seconds between ticks

# injected from LaserWeapon
var muzzle : Node2D
var damage : float
var crit   : float
var range  : float
var max_chain_len : int = 1                   # 1 + reflects_left

# runtime
var chain      : Array[Node] = []             # ordered enemy list
var segments   : Array[Node] = []             # BeamSegment instances
var tick_accum : float = 0.0
var hit_this_tick : = {}                      # Set

const SEGMENT_SCENE : PackedScene = preload("res://scenes/bullets/BeamSegment.tscn")
@onready var pd := get_tree().root.get_node("PlayerData")

# ── public API ───────────────────────────────────────
func set_beam_stats(m: Node2D, first_target: Node,
					dmg: float, cr: float, rng: float, reflects_left: int) -> void:
	muzzle        = m
	damage        = dmg
	crit          = cr
	range         = rng
	max_chain_len = 1 + reflects_left
	_reset_chain(first_target)

# ── main loop ────────────────────────────────────────
func _process(delta: float) -> void:
	if muzzle == null:
		_clear_segments()
		return

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

# ── chain management ────────────────────────────────
func _reset_chain(first_target: Node) -> void:
	_clear_segments()
	chain.clear()
	if is_instance_valid(first_target):
		chain.append(first_target)
		_add_segment(muzzle.global_position, first_target.global_position)

func _prune_chain() -> void:
	for i in range(chain.size()):
		if not _is_valid_enemy(chain[i]):
			chain.resize(i)                # truncate from break point
			_shrink_segments_to(i)         # keep visuals in sync
			break

func _extend_chain() -> void:
	while chain.size() < max_chain_len:
		var tail: Node
		if chain.is_empty():
			tail = null
		else:
			tail = chain.back()
		var nxt  := _find_next_enemy_from(tail)
		if nxt == null: break
		chain.append(nxt)
		var from_pos = tail.global_position if tail else muzzle.global_position
		_add_segment(from_pos, nxt.global_position)

# ── helpers ─────────────────────────────────────────
func _is_valid_enemy(e: Node) -> bool:
	return is_instance_valid(e) and \
		muzzle.global_position.distance_to(e.global_position) < range

func _find_next_enemy_from(from_node: Node) -> Node:
	var origin : Vector2
	if from_node != null:
		origin = from_node.global_position
	else:
		origin = muzzle.global_position

	var best : Node = null
	var best_d := range
	for e in get_tree().get_nodes_in_group("Enemies"):
		if e in chain: continue
		var d = origin.distance_to(e.global_position)
		if d < best_d:
			best_d = d
			best   = e
	return best

# ── damage ──────────────────────────────────────────
func _apply_damage(enemy: Node) -> void:
	if enemy in hit_this_tick: return
	hit_this_tick[enemy] = true
	if not enemy.has_method("take_damage"): return

	var dmg = damage
	if randf() < crit:
		dmg *= pd.get_stat("crit_damage")
	enemy.take_damage(dmg)

# ── segment visual handling ─────────────────────────
func _add_segment(start: Vector2, end: Vector2) -> void:
	var seg = SEGMENT_SCENE.instantiate()
	add_child(seg)
	seg.update_segment(start, end)
	segments.append(seg)

func _update_visuals() -> void:
	if segments.is_empty(): return
	# update first segment
	segments[0].update_segment(muzzle.global_position, chain[0].global_position)
	# update the rest
	for i in range(1, chain.size()):
		segments[i].update_segment(chain[i-1].global_position, chain[i].global_position)

func _shrink_segments_to(count: int) -> void:
	while segments.size() > count:
		segments.back().queue_free()
		segments.pop_back()

func _clear_segments() -> void:
	for s in segments:
		s.queue_free()
	segments.clear()
