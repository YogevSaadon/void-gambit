# scripts/actors/player/MiniShip.gd
extends Node2D
class_name MiniShip

# ===== MOVEMENT STATES =====
enum ShipState {
	ORBIT_PLAYER,     # No enemies - strafe around player
	ENGAGE_ENEMY,     # Enemy found - strafe enemy for 5 seconds
	RETURN_TO_PLAYER  # Emergency return to middle screen
}

# ===== REFERENCES =====
@onready var weapon_slot: Node2D = $WeaponSlot
var current_weapon: BaseWeapon = null
var owner_player: Player = null

# ===== MOVEMENT CONFIGURATION =====
@export var player_orbit_min: float = 50.0       # Closest to player
@export var player_orbit_max: float = 400.0      # Farthest from player (screen edge)
@export var enemy_engage_range: float = 350.0    # Start engaging enemies at this range
@export var max_distance_from_player: float = 800.0  # Return trigger distance
@export var strafe_intensity: float = 1.0        # How much to circle
@export var enemy_strafe_distance: float = 200.0 # Preferred distance from enemy
@export var engage_duration: float = 5.0         # QUICK STAT: How long to strafe each enemy
@export var screen_targeting_range: float = 600.0 # Only target enemies within this range of player

# ===== MOVEMENT STATS =====
var movement_stats: Dictionary = {
	"base_speed": 150.0,      # Normal movement
	"engage_speed": 120.0,    # When fighting (like Triangle)
	"return_speed": 250.0,    # Fast return to player
	"transition_speed": 200.0, # Moving between targets
}

# ===== TARGET & STATE =====
var current_target: Node = null                  # THE TARGET - passed to weapon
var current_state: ShipState = ShipState.ORBIT_PLAYER
var velocity: Vector2 = Vector2.ZERO

# ===== TRIANGLE-STYLE AI VARIABLES =====
var strafe_direction: float = 1.0                # 1.0 or -1.0 (clockwise/counterclockwise)
var orbit_radius: float = 200.0                  # Current orbit distance
var target_orbit_radius: float = 200.0          # Desired orbit distance
var smooth_target_position: Vector2 = Vector2.ZERO

# ===== TIMERS =====
var engage_timer: float = 0.0                    # How long we've been strafing current enemy
var target_switch_timer: float = 0.0             # When to find new enemy
var behavior_change_timer: float = 0.0           # When to change strafe direction
var orbit_change_timer: float = 0.0              # When to change orbit radius

# ===== TIMER INTERVALS =====
const TARGET_UPDATE_INTERVAL: float = 0.2        # How often to find new targets
const BEHAVIOR_CHANGE_INTERVAL: float = 3.0      # How often to change strafe direction  
const ORBIT_CHANGE_INTERVAL: float = 4.0         # How often to change orbit radius
const RADIUS_SMOOTHING: float = 1.5              # How fast to change orbit radius
const TARGET_SMOOTHING: float = 5.0              # How fast to move to new position

# ===== LIFECYCLE =====
func _ready() -> void:
	add_to_group("PlayerShips")
	
	# Set max distance based on screen size
	var screen_size = get_viewport_rect().size
	max_distance_from_player = max(screen_size.x, screen_size.y) * 0.7
	player_orbit_max = max(screen_size.x, screen_size.y) * 0.4  # Screen edge orbit
	
	_initialize_triangle_ai()

func _initialize_triangle_ai() -> void:
	"""Setup Triangle-like randomized behavior"""
	# Random initial values (like Triangle enemy does)
	strafe_direction = 1.0 if randf() > 0.5 else -1.0
	orbit_radius = randf_range(player_orbit_min, player_orbit_max)
	target_orbit_radius = orbit_radius
	
	# Stagger timers so ships don't all change behavior simultaneously
	target_switch_timer = randf() * TARGET_UPDATE_INTERVAL
	behavior_change_timer = randf() * BEHAVIOR_CHANGE_INTERVAL
	orbit_change_timer = randf() * ORBIT_CHANGE_INTERVAL

# ===== MAIN UPDATE LOOP =====
func _physics_process(delta: float) -> void:
	if not is_valid():
		return
	
	_update_timers(delta)
	_update_state_machine()
	_execute_triangle_behavior(delta)
	_apply_movement(delta)
	_update_weapon(delta)

func _update_timers(delta: float) -> void:
	target_switch_timer -= delta
	behavior_change_timer -= delta
	orbit_change_timer -= delta
	if current_state == ShipState.ENGAGE_ENEMY:
		engage_timer += delta

# ===== STATE MACHINE & TARGETING =====
func _update_state_machine() -> void:
	var player = get_player()
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Priority 1: Return if too far from player
	if distance_to_player > max_distance_from_player:
		current_target = null  # NO TARGET when returning
		_change_state(ShipState.RETURN_TO_PLAYER)
		return
	
	# Priority 2: Check if current target is still valid
	if current_target and not is_instance_valid(current_target):
		current_target = null  # Target died - immediately find new one
		engage_timer = 0.0
	
	# Priority 3: Find new enemies (either no target, or time to switch)
	if target_switch_timer <= 0.0 or current_target == null:
		target_switch_timer = TARGET_UPDATE_INTERVAL
		var new_target = _find_nearest_enemy_in_screen_range(player)
		
		# Switch target if we found a new one OR if we've been engaging too long
		if new_target and (new_target != current_target or engage_timer >= engage_duration):
			current_target = new_target  # SET TARGET for weapon
			engage_timer = 0.0  # Reset engage timer
			_change_state(ShipState.ENGAGE_ENEMY)
			return
	
	# Priority 4: If we have a target and haven't been engaging too long, keep engaging
	if current_target and is_instance_valid(current_target) and engage_timer < engage_duration:
		_change_state(ShipState.ENGAGE_ENEMY)
		return
	
	# Priority 5: No enemies or done engaging - orbit player
	current_target = null  # NO TARGET when orbiting player
	_change_state(ShipState.ORBIT_PLAYER)

func _change_state(new_state: ShipState) -> void:
	if current_state != new_state:
		current_state = new_state

# ===== TRIANGLE-STYLE MOVEMENT =====
func _execute_triangle_behavior(delta: float) -> void:
	var target_position = global_position
	var speed_multiplier = 1.0
	
	# Handle random behavior changes (like Triangle enemy)
	_handle_random_behavior_changes()
	
	match current_state:
		ShipState.ORBIT_PLAYER:
			target_position = _calculate_player_orbit_position()
			speed_multiplier = 1.0
			
		ShipState.ENGAGE_ENEMY:
			target_position = _calculate_enemy_strafe_position()
			speed_multiplier = 0.8  # Slower when engaging (like Triangle)
			
		ShipState.RETURN_TO_PLAYER:
			target_position = _calculate_return_position()
			speed_multiplier = 1.67  # Faster return
	
	# Smooth movement (like Triangle)
	smooth_target_position = smooth_target_position.lerp(target_position, TARGET_SMOOTHING * delta)
	orbit_radius = lerp(orbit_radius, target_orbit_radius, RADIUS_SMOOTHING * delta)
	
	var desired_direction = (smooth_target_position - global_position).normalized()
	var base_speed = movement_stats.get("base_speed", 150.0)
	velocity = desired_direction * base_speed * speed_multiplier

func _handle_random_behavior_changes() -> void:
	"""Random behavior changes like Triangle enemy"""
	
	# Change strafe direction occasionally
	if behavior_change_timer <= 0.0:
		behavior_change_timer = BEHAVIOR_CHANGE_INTERVAL
		if randf() < 0.33:  # 33% chance like Triangle
			strafe_direction *= -1.0
	
	# Change orbit radius occasionally (only when orbiting player)
	if current_state == ShipState.ORBIT_PLAYER and orbit_change_timer <= 0.0:
		orbit_change_timer = ORBIT_CHANGE_INTERVAL
		if randf() < 0.5:  # 50% chance to change orbit distance
			if randf() < 0.6:
				# Usually stay in outer range
				target_orbit_radius = randf_range(player_orbit_max * 0.7, player_orbit_max)
			else:
				# Sometimes go close to player
				target_orbit_radius = randf_range(player_orbit_min, player_orbit_max * 0.4)

func _calculate_player_orbit_position() -> Vector2:
	"""Triangle-like orbiting around player"""
	var player = get_player()
	if not player:
		return global_position
	
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	
	# Calculate strafe position (perpendicular to player direction)
	var perp = Vector2(-to_player.y, to_player.x).normalized()
	var strafe_offset = perp * strafe_direction * strafe_intensity * 60.0
	
	# Maintain orbit distance from player
	var orbit_position = player.global_position - to_player.normalized() * orbit_radius
	return orbit_position + strafe_offset

func _calculate_enemy_strafe_position() -> Vector2:
	"""Triangle-like strafing around enemy (exactly like Triangle vs player)"""
	if not current_target or not is_instance_valid(current_target):
		return global_position
	
	var to_enemy = current_target.global_position - global_position
	var distance = to_enemy.length()
	
	# Calculate strafe position (perpendicular to enemy direction)
	var perp = Vector2(-to_enemy.y, to_enemy.x).normalized()
	var strafe_offset = perp * strafe_direction * strafe_intensity * 50.0
	
	# Maintain distance from enemy (like Triangle maintains distance from player)
	var strafe_position = current_target.global_position - to_enemy.normalized() * enemy_strafe_distance
	return strafe_position + strafe_offset

func _calculate_return_position() -> Vector2:
	"""Return to middle of screen (where player should be)"""
	var screen_size = get_viewport_rect().size
	return Vector2(screen_size.x * 0.5, screen_size.y * 0.5)

# ===== TARGET FINDING (Using fast Godot physics system) =====
func _find_nearest_enemy_in_screen_range(player: Player) -> Node:
	"""Find closest enemy to SHIP within screen range of PLAYER (using fast physics query)"""
	if not player:
		return null
	
	# Use Godot's built-in physics queries (fast C++ backend)
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsShapeQueryParameters2D.new()
	
	# Create a circle shape around the PLAYER (screen range)
	var circle = CircleShape2D.new()
	circle.radius = screen_targeting_range
	
	# Set up the query parameters centered on PLAYER
	params.shape = circle
	params.transform = Transform2D(0, player.global_position)
	params.collision_mask = 1 << 2  # Only check enemy layer (layer 2)
	params.collide_with_areas = true
	params.collide_with_bodies = false
	
	# Query physics engine for enemies in range of player
	var results = space_state.intersect_shape(params, 32)  # Max 32 results
	
	# Find the closest enemy to THE SHIP (not player)
	var best_enemy = null
	var best_distance_sq = enemy_engage_range * enemy_engage_range
	
	for result in results:
		var enemy = result.collider
		if not is_instance_valid(enemy):
			continue
		
		# Calculate distance from SHIP to enemy (not player to enemy)
		var distance_sq = global_position.distance_squared_to(enemy.global_position)
		if distance_sq < best_distance_sq:
			best_distance_sq = distance_sq
			best_enemy = enemy
	
	return best_enemy

# ===== MOVEMENT APPLICATION =====
func _apply_movement(delta: float) -> void:
	"""Apply calculated velocity to ship position"""
	global_position += velocity * delta
	
	# Rotate ship to face movement direction
	if velocity.length() > 10.0:
		rotation = lerp_angle(rotation, velocity.angle(), 3.0 * delta)

# ===== WEAPON MANAGEMENT =====
func setup_weapon(weapon: BaseWeapon) -> void:
	"""Called by spawner to attach weapon (already configured with stats)"""
	if not weapon_slot:
		push_error("MiniShip: WeaponSlot not found!")
		return
	
	current_weapon = weapon
	# Weapon comes pre-configured by spawner

func _update_weapon(delta: float) -> void:
	"""Update weapon and pass current target"""
	if not current_weapon:
		return
	
	# PASS TARGET TO WEAPON
	if current_weapon.has_method("set_forced_target"):
		current_weapon.set_forced_target(current_target)
	
	# Let weapon auto-fire at the forced target
	if current_weapon.has_method("auto_fire"):
		current_weapon.auto_fire(delta)

# ===== UTILITY METHODS =====
func set_owner_player(player: Player) -> void:
	"""Set the player this ship belongs to"""
	owner_player = player

func get_player() -> Player:
	"""Get reference to owner player"""
	return owner_player

func is_valid() -> bool:
	"""Check if ship is still valid (player exists, etc.)"""
	return is_instance_valid(owner_player)

func get_current_target() -> Node:
	"""Get current target for weapon"""
	return current_target

# ===== CLEANUP =====
func destroy() -> void:
	"""Clean up ship when it's no longer needed"""
	if current_weapon:
		current_weapon.queue_free()
	queue_free()

func _exit_tree() -> void:
	# Clean up any references
	current_weapon = null
	owner_player = null
	current_target = null
