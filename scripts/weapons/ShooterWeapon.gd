# res://scripts/weapons/ShooterWeapon.gd
extends BaseWeapon
class_name ShooterWeapon

# ─── Runtime ──────────────────────────────────────────
var cooldown_timer : float = 0.0
var current_target : Node  = null

# ─── Engine callbacks ─────────────────────────────────
func _physics_process(delta: float) -> void:
	current_target = _find_target_in_range()
	if current_target:
		look_at(current_target.global_position)

	if cooldown_timer > 0.0:
		cooldown_timer -= delta

func auto_fire(_delta: float) -> void:
	if cooldown_timer > 0.0:
		return

	# Make sure the target is still a live Node before firing
	if is_instance_valid(current_target):
		_fire_once(current_target)
		cooldown_timer = 1.0 / final_fire_rate

# ─── Hooks for concrete subclasses ────────────────────
func _fire_once(_target: Node) -> void:
	push_warning("%s: _fire_once() not implemented" % self)

# ─── Helpers ─────────────────────────────────────────
func _find_target_in_range() -> Node:
	var best_target : Node  = null
	var best_dist   : float = final_range          # final_range is set in BaseWeapon.apply_weapon_modifiers()

	for enemy in get_tree().get_nodes_in_group("Enemies"):
		var d = global_position.distance_to(enemy.global_position)
		if d < best_dist:
			best_dist   = d
			best_target = enemy
	return best_target
