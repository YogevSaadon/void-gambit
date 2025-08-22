# scripts/weapons/ShooterWeapon.gd
extends BaseWeapon
class_name ShooterWeapon

var cooldown_timer: float = 0.0
var current_target: Node = null

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

func apply_weapon_modifiers(pd: PlayerData) -> void:
	super.apply_weapon_modifiers(pd)

func _fire_once(_target: Node) -> void:
	push_warning("%s: _fire_once() not implemented" % self)

func _find_target_in_range() -> Node:
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsShapeQueryParameters2D.new()
	
	var circle = CircleShape2D.new()
	circle.radius = final_range
	
	params.shape = circle
	params.transform = Transform2D(0, global_position)
	params.collision_mask = 1 << CollisionLayers.LAYER_ENEMIES
	params.collide_with_areas = true
	params.collide_with_bodies = false
	
	# Spatial query returns max 32 nearby enemies
	var results = space_state.intersect_shape(params, PerformanceConstants.MAX_PHYSICS_QUERY_RESULTS)
	
	# Find closest in small result set (O(32), not O(all_enemies))
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
