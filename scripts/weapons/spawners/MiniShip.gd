# scripts/weapons/spawners/MiniShip.gd
extends Node2D
class_name MiniShip

# ===== AUTONOMOUS COMBAT AI SYSTEM =====
# DOMAIN: Player-owned ships that operate independently in bullet hell combat
# CHALLENGE: Balance autonomous behavior with responsive player support
# SOLUTION: 3-state AI with tactical positioning and optimized target acquisition

enum ShipState {
	RETURN_TO_RANGE,   # Too far - return to player
	FIND_TARGET,       # In range - looking for enemy
	ENGAGE_TARGET      # Has target - attacking
}

var current_weapon: BaseShipWeapon = null
var owner_player: Player = null
var current_target: Node = null
var current_state: ShipState = ShipState.FIND_TARGET

# ===== MOVEMENT CONFIGURATION =====
@export var max_range_from_player: float = 400.0    # Max distance before returning
@export var comfort_range: float = 250.0            # Preferred distance from player
@export var attack_range: float = 200.0             # Distance to maintain from target
@export var target_search_range: float = 350.0      # Range to find enemies

@export var cruise_speed: float = 150.0             # Normal movement speed
@export var return_speed: float = 300.0             # Speed when returning to player
@export var combat_speed: float = 180.0             # Speed in combat

@export var acceleration: float = 800.0             # How fast to change velocity
@export var rotation_speed: float = 8.0             # How fast to rotate

var velocity: Vector2 = Vector2.ZERO
var desired_velocity: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO

# ===== PERFORMANCE OPTIMIZATION =====
var target_check_timer: float = 0.0
const TARGET_CHECK_INTERVAL: float = 0.2  # Staggered target acquisition

func _ready() -> void:
	add_to_group("PlayerShips")
	
	if not has_node("WeaponAttachment"):
		var attachment = Node2D.new()
		attachment.name = "WeaponAttachment"
		add_child(attachment)
	
	if owner_player:
		global_position = owner_player.global_position

func _physics_process(delta: float) -> void:
	if not is_instance_valid(owner_player):
		queue_free()
		return
	
	_update_state_machine(delta)
	_calculate_movement()
	
	# SMOOTH MOVEMENT: Acceleration-based physics for natural feel
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	position += velocity * delta
	
	# VISUAL POLISH: Rotate to face movement direction
	if velocity.length() > 20.0:
		var target_rotation = velocity.angle()
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
	
	_update_weapon_target()

# ===== AI STATE MACHINE =====
func _update_state_machine(delta: float) -> void:
	"""
	TACTICAL AI: Balances player support with autonomous combat effectiveness
	"""
	var distance_to_player = global_position.distance_to(owner_player.global_position)
	
	# EMERGENCY RECALL: Force return if too far from player
	if distance_to_player > max_range_from_player:
		if current_state != ShipState.RETURN_TO_RANGE:
			current_state = ShipState.RETURN_TO_RANGE
			current_target = null
		return
	
	match current_state:
		ShipState.RETURN_TO_RANGE:
			if distance_to_player < comfort_range:
				current_state = ShipState.FIND_TARGET
		
		ShipState.FIND_TARGET:
			# STAGGERED TARGETING: Prevents simultaneous expensive searches
			target_check_timer -= delta
			if target_check_timer <= 0.0:
				target_check_timer = TARGET_CHECK_INTERVAL
				current_target = _find_best_target()
				
				if current_target:
					current_state = ShipState.ENGAGE_TARGET
		
		ShipState.ENGAGE_TARGET:
			if not _is_target_valid():
				current_target = null
				current_state = ShipState.FIND_TARGET
				target_check_timer = 0.0  # Immediate search for new target

func _calculate_movement() -> void:
	match current_state:
		ShipState.RETURN_TO_RANGE:
			_move_to_player()
		ShipState.FIND_TARGET:
			_patrol_movement()
		ShipState.ENGAGE_TARGET:
			_combat_movement()

func _move_to_player() -> void:
	# SMART RETURN: Target area near player, not exact position
	var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
	target_position = owner_player.global_position + offset
	
	var direction = (target_position - global_position).normalized()
	desired_velocity = direction * return_speed

func _patrol_movement() -> void:
	"""ESCORT BEHAVIOR: Maintain formation while searching for threats"""
	var to_player = owner_player.global_position - global_position
	var distance = to_player.length()
	
	if distance > comfort_range * 0.8:
		desired_velocity = to_player.normalized() * cruise_speed
	else:
		# ORBITAL MOVEMENT: Gentle circulation around player
		var tangent = Vector2(-to_player.y, to_player.x).normalized()
		desired_velocity = tangent * cruise_speed * 0.5
		desired_velocity += to_player.normalized() * cruise_speed * 0.2

func _combat_movement() -> void:
	"""TACTICAL POSITIONING: Maintain optimal range for weapon effectiveness"""
	if not current_target or not is_instance_valid(current_target):
		return
	
	var to_target = current_target.global_position - global_position
	var distance = to_target.length()
	
	# RANGE MANAGEMENT: Balance damage output with survivability
	if distance > attack_range * 1.2:
		desired_velocity = to_target.normalized() * combat_speed
	elif distance < attack_range * 0.8:
		desired_velocity = -to_target.normalized() * combat_speed * 0.7
	else:
		# EVASIVE MANEUVERING: Strafe to avoid incoming fire
		var tangent = Vector2(-to_target.y, to_target.x).normalized()
		if randf() < 0.02:  # Occasional direction change for unpredictability
			tangent *= -1
		desired_velocity = tangent * combat_speed * 0.8

func _find_best_target() -> Node:
	"""
	GODOT PHYSICS ENGINE: intersect_shape() uses C++ spatial hash for combat responsiveness
	GODOT GROUPS SYSTEM: Alternative approach would use get_nodes_in_group() (also optimized)
	ARCHITECTURE: Both methods leverage engine optimization, spatial queries scale better
	PERFORMANCE: Consistent performance regardless of enemy count
	"""
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsShapeQueryParameters2D.new()
	
	var circle = CircleShape2D.new()
	circle.radius = target_search_range
	
	params.shape = circle
	params.transform = Transform2D(0, global_position)
	params.collision_mask = 1 << 2  # Enemy layer
	params.collide_with_areas = true
	params.collide_with_bodies = false
	
	var results = space_state.intersect_shape(params, 32)
	
	var best_enemy = null
	var best_dist_sq = target_search_range * target_search_range
	
	for result in results:
		var enemy = result.collider
		if is_instance_valid(enemy) and enemy.is_in_group("Enemies"):
			var dist_sq = global_position.distance_squared_to(enemy.global_position)
			if dist_sq < best_dist_sq:
				best_dist_sq = dist_sq
				best_enemy = enemy
	
	return best_enemy

func _is_target_valid() -> bool:
	if not current_target or not is_instance_valid(current_target):
		return false
	
	var distance = global_position.distance_to(current_target.global_position)
	if distance > target_search_range * 1.5:
		return false
	
	# LIVENESS CHECK: Ensure target hasn't been destroyed
	if current_target.has_method("get_actor_stats"):
		var stats = current_target.get_actor_stats()
		if stats.get("hp", 0) <= 0:
			return false
	
	return true

# ===== WEAPON INTEGRATION =====
func setup_weapon(weapon: BaseShipWeapon) -> void:
	if not weapon:
		push_error("MiniShip: Null weapon passed to setup_weapon!")
		return
	
	current_weapon = weapon
	var attachment = get_node_or_null("WeaponAttachment")
	if attachment:
		attachment.add_child(weapon)
		weapon.set_owner_ship(self)
	else:
		push_error("MiniShip: WeaponAttachment node not found!")

func _update_weapon_target() -> void:
	# WEAPON COORDINATION: Only provide target during active engagement
	if current_weapon and is_instance_valid(current_weapon):
		if current_state == ShipState.ENGAGE_TARGET and _is_target_valid():
			current_weapon.set_forced_target(current_target)
		else:
			current_weapon.set_forced_target(null)

func set_owner_player(player: Player) -> void:
	owner_player = player
	if owner_player:
		global_position = owner_player.global_position

func get_current_state_name() -> String:
	match current_state:
		ShipState.RETURN_TO_RANGE: return "Returning"
		ShipState.FIND_TARGET: return "Searching"
		ShipState.ENGAGE_TARGET: return "Engaging"
		_: return "Unknown"

func get_debug_info() -> Dictionary:
	return {
		"state": get_current_state_name(),
		"target": current_target.name if current_target else "None",
		"velocity": velocity.length(),
		"distance_to_player": global_position.distance_to(owner_player.global_position) if owner_player else 0
	}

func _exit_tree() -> void:
	if current_weapon:
		current_weapon.queue_free()
	current_target = null
	owner_player = null
