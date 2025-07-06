# scripts/weapons/spawners/MiniShip.gd
extends Node2D
class_name MiniShip

# ===== MOVEMENT STATES =====
enum ShipState {
	ORBIT_PLAYER,      # Default - orbit around player
	ENGAGE_ENEMY,      # Found enemy - orbit and shoot
	RETURN_TO_PLAYER   # Too far - return quickly
}

# ===== REFERENCES =====
var current_weapon: BaseShipWeapon = null
var owner_player: Player = null
var current_target: Node = null
var current_state: ShipState = ShipState.ORBIT_PLAYER

# ===== MOVEMENT CONFIG =====
@export var orbit_radius: float = 150.0          # Distance from player when orbiting
@export var enemy_orbit_radius: float = 180.0    # Distance from enemy when engaging
@export var screen_range: float = 500.0          # Max range to find enemies
@export var return_threshold: float = 600.0      # Distance before returning to player
@export var engage_time: float = 3.0             # Time to engage each enemy

# ===== SPEEDS =====
@export var orbit_speed: float = 120.0           # Speed when orbiting
@export var engage_speed: float = 100.0          # Speed when fighting (slower)
@export var return_speed: float = 250.0          # Speed when returning (faster)
@export var transition_speed: float = 180.0      # Speed when switching targets

# ===== MOVEMENT VARIABLES =====
var velocity: Vector2 = Vector2.ZERO
var orbit_angle: float = 0.0                     # Current angle around orbit target
var orbit_direction: float = 1.0                 # 1 or -1 for clockwise/counter
var smooth_position: Vector2 = Vector2.ZERO      # For smooth movement
var engage_timer: float = 0.0                    # Time spent on current enemy

# ===== INITIALIZATION =====
func _ready() -> void:
	add_to_group("PlayerShips")
	
	# Random starting position in orbit
	orbit_angle = randf() * TAU
	orbit_direction = 1.0 if randf() > 0.5 else -1.0
	
	# Create weapon attachment point if it doesn't exist
	if not has_node("WeaponAttachment"):
		var attachment = Node2D.new()
		attachment.name = "WeaponAttachment"
		add_child(attachment)

# ===== MAIN UPDATE =====
func _physics_process(delta: float) -> void:
	if not is_instance_valid(owner_player):
		queue_free()
		return
	
	# Update state machine
	_update_state()
	
	# Execute movement based on state
	match current_state:
		ShipState.ORBIT_PLAYER:
			_orbit_player(delta)
		ShipState.ENGAGE_ENEMY:
			_engage_enemy(delta)
		ShipState.RETURN_TO_PLAYER:
			_return_to_player(delta)
	
	# Apply movement
	global_position = global_position.lerp(smooth_position, 10.0 * delta)
	
	# Rotate to face movement direction
	if velocity.length() > 10.0:
		rotation = lerp_angle(rotation, velocity.angle(), 5.0 * delta)

# ===== STATE MACHINE =====
func _update_state() -> void:
	var distance_to_player = global_position.distance_to(owner_player.global_position)
	
	# Priority 1: Return if too far
	if distance_to_player > return_threshold:
		if current_state != ShipState.RETURN_TO_PLAYER:
			current_target = null
			current_state = ShipState.RETURN_TO_PLAYER
		return
	
	# Priority 2: Check current target validity
	if current_target and not is_instance_valid(current_target):
		current_target = null
		engage_timer = 0.0
	
	# Priority 3: Handle engagement
	match current_state:
		ShipState.RETURN_TO_PLAYER:
			# Switch to orbit when close enough
			if distance_to_player < orbit_radius * 2:
				current_state = ShipState.ORBIT_PLAYER
		
		ShipState.ENGAGE_ENEMY:
			engage_timer += get_physics_process_delta_time()
			# Time to find new target or go back to orbiting
			if engage_timer >= engage_time or not current_target:
				current_target = _find_closest_enemy()
				engage_timer = 0.0
				if not current_target:
					current_state = ShipState.ORBIT_PLAYER
		
		ShipState.ORBIT_PLAYER:
			# Look for enemies periodically
			if randf() < 0.02:  # 2% chance per frame (~once per second)
				current_target = _find_closest_enemy()
				if current_target:
					engage_timer = 0.0
					current_state = ShipState.ENGAGE_ENEMY

# ===== MOVEMENT BEHAVIORS =====
func _orbit_player(delta: float) -> void:
	"""Calm orbit around player"""
	# Update orbit angle
	var angular_speed = orbit_speed / orbit_radius
	orbit_angle += angular_speed * orbit_direction * delta
	
	# Occasionally change direction
	if randf() < 0.005:  # 0.5% chance per frame
		orbit_direction *= -1.0
	
	# Calculate target position
	var offset = Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	smooth_position = owner_player.global_position + offset
	velocity = (smooth_position - global_position).normalized() * orbit_speed

func _engage_enemy(delta: float) -> void:
	"""Orbit around enemy while shooting"""
	if not current_target or not is_instance_valid(current_target):
		current_state = ShipState.ORBIT_PLAYER
		return
	
	# Similar to player orbit but around enemy
	var angular_speed = engage_speed / enemy_orbit_radius
	orbit_angle += angular_speed * orbit_direction * delta * 1.5  # Faster orbiting
	
	var offset = Vector2(cos(orbit_angle), sin(orbit_angle)) * enemy_orbit_radius
	smooth_position = current_target.global_position + offset
	velocity = (smooth_position - global_position).normalized() * engage_speed

func _return_to_player(delta: float) -> void:
	"""Quick return to player"""
	smooth_position = owner_player.global_position
	velocity = (smooth_position - global_position).normalized() * return_speed

# ===== TARGETING =====
func _find_closest_enemy() -> Node:
	"""Find closest enemy within screen range using physics query"""
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsShapeQueryParameters2D.new()
	
	var circle = CircleShape2D.new()
	circle.radius = screen_range
	
	params.shape = circle
	params.transform = Transform2D(0, global_position)
	params.collision_mask = 1 << 2  # Enemy layer
	params.collide_with_areas = true
	params.collide_with_bodies = false
	
	var results = space_state.intersect_shape(params, 32)
	
	var best_enemy = null
	var best_dist_sq = screen_range * screen_range
	
	for result in results:
		var enemy = result.collider
		if is_instance_valid(enemy):
			var dist_sq = global_position.distance_squared_to(enemy.global_position)
			if dist_sq < best_dist_sq:
				best_dist_sq = dist_sq
				best_enemy = enemy
	
	return best_enemy

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

func _process(_delta: float) -> void:
	"""Update weapon targeting"""
	if current_weapon and is_instance_valid(current_weapon):
		current_weapon.set_forced_target(current_target)

# ===== UTILITIES =====
func set_owner_player(player: Player) -> void:
	owner_player = player

func get_current_state_name() -> String:
	match current_state:
		ShipState.ORBIT_PLAYER: return "Orbiting Player"
		ShipState.ENGAGE_ENEMY: return "Engaging Enemy"
		ShipState.RETURN_TO_PLAYER: return "Returning"
		_: return "Unknown"

# ===== CLEANUP =====
func _exit_tree() -> void:
	if current_weapon:
		current_weapon.queue_free()
	current_target = null
	owner_player = null
