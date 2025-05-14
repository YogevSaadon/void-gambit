extends Node2D
class_name LaserBeamController

@export var tick_time := 0.05          # how often damage is applied (sec)

# ── runtime parameters set by LaserWeapon ──
var muzzle : Node2D      = null
var target : Node        = null
var damage : float       = 10.0
var crit   : float       = 0.0
var range  : float       = 500.0

@onready var seg := $BeamSegment       # visual + raycast child

var tick_accum    : float = 0.0
var hit_this_tick : = {}               # Set[Any] to avoid double‑hits in 1 tick

# ──────────────────────────────────────────────────────
# Called once by LaserWeapon after instantiating/refresh
func set_beam_stats(m: Node2D, t: Node,
					dmg: float, cr: float, rng: float) -> void:
	muzzle  = m
	target  = t
	damage  = dmg
	crit    = cr
	range   = rng
	_update_visual()

# ──────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if muzzle == null:          # weapon unequipped
		hide(); return

	hit_this_tick.clear()

	if not _validate_or_retarget():
		hide(); return

	show()
	_update_visual()

	tick_accum += delta
	if tick_accum >= tick_time:
		tick_accum = 0.0
		_apply_damage(target)

# ─── Target validation + retarget logic ───────────────
func _validate_or_retarget() -> bool:
	if not is_instance_valid(target):
		target = _find_closest_enemy()
	else:
		var dist = muzzle.global_position.distance_to(target.global_position)
		if dist >= range:
			target = _find_closest_enemy()
		else:
			var closer = _find_closest_enemy()
			if closer and closer != target:
				target = closer
	return target != null

func _find_closest_enemy() -> Node:
	var best : Node = null
	var best_d := range          # cap by range
	for e in get_tree().get_nodes_in_group("Enemies"):
		var d = muzzle.global_position.distance_to(e.global_position)
		if d < best_d:
			best_d = d
			best   = e
	return best

# ─── Visual & raycast update ──────────────────────────
func _update_visual() -> void:
	seg.update_segment(muzzle.global_position, target.global_position)

# ─── Damage tick (no double‑hit per tick) ─────────────
func _apply_damage(enemy: Node) -> void:
	if enemy in hit_this_tick: return
	hit_this_tick[enemy] = true

	if not enemy.has_method("take_damage"): return

	var dmg = damage
	if randf() < crit:
		var pd = get_tree().root.get_node("PlayerData")
		dmg *= pd.get_stat("crit_damage")
	enemy.take_damage(dmg)
