# scripts/weapons/spawners/MiniShip.gd
extends Node2D
class_name MiniShip

# ===== MOVEMENT STATES =====
enum ShipState {
	RETURN_TO_RANGE,   # Too far - return to player
	FIND_TARGET,       # In range - looking for enemy
	ENGAGE_TARGET      # Has target - attacking
}

# ===== REFERENCES =====
var current_weapon: BaseShipWeapon = null
var owner_player: Player = null
var current_target: Node = null
var current_state: ShipState = ShipState.FIND_TARGET

# ===== MOVEMENT CONFIGURATION =====
@export var max_range_from_player: float = 400.0    # Max distance before returning
@export var comfort_range: float = 250.0            # Preferred distance from player
@export var attack_range: float = 200.0             # Distance to maintain from target
@export var target_search_range: float = 350.0      # Range to find enemies

# ===== MOVEMENT SPEEDS =====
@export var cruise_speed: float = 150.0             # Normal movement speed
@export var return_speed: float = 300.0             # Speed when returning to player
@export var combat_speed: float = 180.0             # Speed in combat

# ===== MOVEMENT SMOOTHING =====
@export var acceleration: float = 800.0             # How fast to change velocity
@export var rotation_speed: float = 8.0             # How fast to rotate

# ===== MOVEMENT VARIABLES =====
var velocity: Vector2 = Vector2.ZERO
var desired_velocity: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO

# ===== TARGETING =====
var target_check_timer: float = 0.0
const TARGET_CHECK_INTERVAL: float = 0.2  # Check for new targets 5x per second

# ===== INITIALIZATION =====
func _ready() -> void:
	add_to_group("PlayerShips")
	
	# Create weapon attachment point if it doesn't exist
	if not has_node("WeaponAttachment"):
		var attachment = Node2D.new()
		attachment.name = "WeaponAttachment"
		add_child(attachment)
	
	# Start at player position
	if owner_player:
		global_position = owner_player.global_position

# ===== MAIN UPDATE =====
func _physics_process(delta: float) -> void:
	if not is_instance_valid(owner_player):
		queue_free()
		return
	
	# Update state machine
	_update_state_machine(delta)
	
	# Calculate movement based on state
	_calculate_movement()
	
	# Apply smooth acceleration
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	
	# Apply movement
	position += velocity * delta
	
	# Smooth rotation to face movement direction
	if velocity.length() > 20.0:
		var target_rotation = velocity.angle()
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
	
	# Update weapon targeting
	_update_weapon_target()

# ===== STATE MACHINE =====
func _update_state_machine(delta: float) -> void:
	var distance_to_player = global_position.distance_to(owner_player.global_position)
	
	# Check if we need to return to player
	if distance_to_player > max_range_from_player:
		if current_state != ShipState.RETURN_TO_RANGE:
			current_state = ShipState.RETURN_TO_RANGE
			current_target = null
		return
	
	# Handle state transitions
	match current_state:
		ShipState.RETURN_TO_RANGE:
			# Switch to finding targets when close enough
			if distance_to_player < comfort_range:
				current_state = ShipState.FIND_TARGET
		
		ShipState.FIND_TARGET:
			# Periodically look for targets
			target_check_timer -= delta
			if target_check_timer <= 0.0:
				target_check_timer = TARGET_CHECK_INTERVAL
				current_target = _find_best_target()
				
				if current_target:
					current_state = ShipState.ENGAGE_TARGET
		
		ShipState.ENGAGE_TARGET:
			# Check if target is still valid
			if not _is_target_valid():
				current_target = null
				current_state = ShipState.FIND_TARGET
				target_check_timer = 0.0  # Find new target immediately

# ===== MOVEMENT CALCULATION =====
func _calculate_movement() -> void:
	match current_state:
		ShipState.RETURN_TO_RANGE:
			_move_to_player()
		ShipState.FIND_TARGET:
			_patrol_movement()
		ShipState.ENGAGE_TARGET:
			_combat_movement()

func _move_to_player() -> void:
	"""Quick return to player vicinity"""
	# Move to a point near the player, not directly on them
	var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
	target_position = owner_player.global_position + offset
	
	var direction = (target_position - global_position).normalized()
	desired_velocity = direction * return_speed

func _patrol_movement() -> void:
	"""Gentle movement around player while searching"""
	# Maintain comfortable distance from player
	var to_player = owner_player.global_position - global_position
	var distance = to_player.length()
	
	if distance > comfort_range * 0.8:
		# Move closer if too far
		desired_velocity = to_player.normalized() * cruise_speed
	else:
		# Gentle orbit/drift movement
		var tangent = Vector2(-to_player.y, to_player.x).normalized()
		desired_velocity = tangent * cruise_speed * 0.5
		
		# Add slight inward pull to stay close
		desired_velocity += to_player.normalized() * cruise_speed * 0.2

func _combat_movement() -> void:
	"""Engage target with smart positioning"""
	if not current_target or not is_instance_valid(current_target):
		return
	
	var to_target = current_target.global_position - global_position
	var distance = to_target.length()
	
	# Maintain attack range
	if distance > attack_range * 1.2:
		# Move closer
		desired_velocity = to_target.normalized() * combat_speed
	elif distance < attack_range * 0.8:
		# Back away
		desired_velocity = -to_target.normalized() * combat_speed * 0.7
	else:
		# Strafe around target
		var tangent = Vector2(-to_target.y, to_target.x).normalized()
		# Random strafe direction that changes occasionally
		if randf() < 0.02:  # 2% chance per frame
			tangent *= -1
		desired_velocity = tangent * combat_speed * 0.8

# ===== TARGETING SYSTEM =====
func _find_best_target() -> Node:
	"""
	Find closest enemy using optimized physics query.
	
	PERFORMANCE: Uses Godot's C++ physics engine for O(log n) spatial queries 
	via PhysicsServer2D instead of O(n) iteration through all enemies.
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
	
	# Execute spatial query - leverages C++ backend optimization
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
	"""Check if current target is still valid"""
	if not current_target or not is_instance_valid(current_target):
		return false
	
	# Check if target is too far
	var distance = global_position.distance_to(current_target.global_position)
	if distance > target_search_range * 1.5:
		return false
	
	# Check if target is still alive (has health)
	if current_target.has_method("get_actor_stats"):
		var stats = current_target.get_actor_stats()
		if stats.get("hp", 0) <= 0:
			return false
	
	return true

# ===== WEAPON MANAGEMENT =====
func setup_weapon(weapon: BaseShipWeapon) -> void:
	"""Attach weapon to ship"""
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
	"""Update weapon with current target"""
	if current_weapon and is_instance_valid(current_weapon):
		# Only give weapon a target if we're engaged
		if current_state == ShipState.ENGAGE_TARGET and _is_target_valid():
			current_weapon.set_forced_target(current_target)
		else:
			current_weapon.set_forced_target(null)

# ===== UTILITIES =====
func set_owner_player(player: Player) -> void:
	owner_player = player
	# Start near player
	if owner_player:
		global_position = owner_player.global_position

func get_current_state_name() -> String:
	match current_state:
		ShipState.RETURN_TO_RANGE: return "Returning"
		ShipState.FIND_TARGET: return "Searching"
		ShipState.ENGAGE_TARGET: return "Engaging"
		_: return "Unknown"

# ===== DEBUG =====
func get_debug_info() -> Dictionary:
	return {
		"state": get_current_state_name(),
		"target": current_target.name if current_target else "None",
		"velocity": velocity.length(),
		"distance_to_player": global_position.distance_to(owner_player.global_position) if owner_player else 0
	}

# ===== CLEANUP =====
func _exit_tree() -> void:
	if current_weapon:
		current_weapon.queue_free()
	current_target = null
	owner_player = null
