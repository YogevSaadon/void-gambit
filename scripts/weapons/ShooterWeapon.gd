extends BaseWeapon
class_name ShooterWeapon

# ─── Exported defaults ───────────────────────────────
@export var base_fire_rate : float = 1.0     # shots per second

# ─── Runtime ─────────────────────────────────────────
var final_fire_rate : float = 1.0            # set in apply_weapon_modifiers()
var cooldown_timer  : float = 0.0
var current_target  : Node  = null

# ─── Engine callbacks ────────────────────────────────
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

# ─── Optimized targeting using Godot's built-in physics ───────────
func _find_target_in_range() -> Node:
	# Use Godot's built-in physics queries
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsShapeQueryParameters2D.new()
	
	# Create a circle shape for our weapon range
	var circle = CircleShape2D.new()
	circle.radius = final_range
	
	# Set up the query parameters
	params.shape = circle
	params.transform = Transform2D(0, global_position)
	params.collision_mask = 1 << 2  # Only check enemy layer (layer 2)
	params.collide_with_areas = true
	params.collide_with_bodies = false
	
	# Query physics engine for enemies in range
	var results = space_state.intersect_shape(params, 32)  # Max 32 results
	
	# Find the closest enemy from results
	var best_enemy = null
	var best_dist_sq = final_range * final_range
	
	for result in results:
		var enemy = result.collider
		if is_instance_valid(enemy):
			var dist_sq = global_position.distance_squared_to(enemy.global_position)
			if dist_sq < best_dist_sq:
				best_dist_sq = dist_sq
				best_enemy = enemy
	
	return best_enemy
