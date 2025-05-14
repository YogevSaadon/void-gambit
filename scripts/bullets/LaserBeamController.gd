extends Node2D
class_name LaserBeamController

@export var tick_time := 0.05

var muzzle : Node2D
var target : Node
var damage : float
var crit   : float
var range  : float

var tick_accum := 0.0
var hit_this_tick := {}

@onready var seg := $BeamSegment

# called by LaserWeapon
func set_beam_stats(m: Node2D, t: Node,
					dmg: float, cr: float, rng: float) -> void:
	muzzle  = m
	target  = t
	damage  = dmg
	crit    = cr
	range   = rng
	_update_visual()

func _process(delta: float) -> void:
	if muzzle == null:
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
	var best_d := range
	for e in get_tree().get_nodes_in_group("Enemies"):
		var d = muzzle.global_position.distance_to(e.global_position)
		if d < best_d:
			best_d = d
			best   = e
	return best

func _update_visual() -> void:
	seg.update_segment(muzzle.global_position, target.global_position)

func _apply_damage(enemy: Node) -> void:
	if enemy in hit_this_tick: return
	hit_this_tick[enemy] = true
	if not enemy.has_method("take_damage"): return
	var dmg = damage
	if randf() < crit:
		var pd = get_tree().root.get_node("PlayerData")
		dmg *= pd.get_stat("crit_damage")
	enemy.take_damage(dmg)
