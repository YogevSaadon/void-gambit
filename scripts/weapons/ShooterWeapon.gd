extends BaseWeapon
class_name ShooterWeapon

# ─── Exported defaults ───────────────────────────────
@export var base_fire_rate : float = 1.0     # shots per second

# ─── Runtime ─────────────────────────────────────────
var final_fire_rate : float = 1.0            # set in apply_weapon_modifiers()
var cooldown_timer  : float = 0.0
var current_target  : Node  = null

# ─── Targeting optimization ─────────────────────────
var targeting_manager : TargetingManager = null

# ─── Engine callbacks ────────────────────────────────
func _ready() -> void:
	# Find targeting manager (will be added to scene by Level.gd)
	targeting_manager = get_tree().get_first_node_in_group("TargetingManager")

func _physics_process(delta: float) -> void:
	current_target = _find_target_in_range()
	if current_target:
		look_at(current_target.global_position)

	if cooldown_timer > 0.0:
		cooldown_timer -= delta

func auto_fire(_delta: float) -> void:
	if cooldown_timer > 0.0:
		return
	if is_instance_valid(current_target):
		_fire_once(current_target)
		cooldown_timer = 1.0 / final_fire_rate

# ─── Stat application (called by concrete weapon) ────
func apply_weapon_modifiers(pd: PlayerData) -> void:
	super.apply_weapon_modifiers(pd)      # sets damage, range, crit
	# Fire rate is fixed per weapon now
	final_fire_rate = base_fire_rate

# ─── Hooks for concrete subclasses ───────────────────
func _fire_once(_target: Node) -> void:
	push_warning("%s: _fire_once() not implemented" % self)

# ─── Optimized targeting with spatial hash ───────────
func _find_target_in_range() -> Node:
	# Use spatial hash if available, fallback to old method
	if targeting_manager:
		return targeting_manager.find_nearest_enemy_in_range(global_position, final_range)
	else:
		# Fallback to old O(n) method if targeting manager not found
		return _find_target_fallback()

func _find_target_fallback() -> Node:
	var best_target : Node  = null
	var best_dist   : float = final_range

	for enemy in get_tree().get_nodes_in_group("Enemies"):
		var d = global_position.distance_to(enemy.global_position)
		if d < best_dist:
			best_dist   = d
			best_target = enemy
	return best_target
