# scripts/weapons/spawners/EnhancedShipMovement.gd
extends Node2D
class_name EnhancedShipMovement

enum ShipState {
	RETURN_TO_PLAYER,
	PATROL_AROUND_PLAYER, 
	STRAFE_TARGET
}

# ===== SHIP CONFIGURATION =====
@export var max_range_from_player: float = 600.0
@export var comfort_range: float = 350.0
@export var strafe_range_inner: float = 250.0
@export var strafe_range_outer: float = 350.0

@export var return_speed: float = 300.0
@export var patrol_speed: float = 150.0
@export var strafe_speed: float = 180.0

# ===== NEW: PLAYER-RELATIVE MOVEMENT =====
@export var follow_player_movement: bool = true           # Enable/disable the feature
@export var follow_responsiveness: float = 0.8            # How much to follow (0.0-1.0)
@export var follow_max_speed: float = 500.0               # Max speed when following player

# ===== PLAYER MOVEMENT TRACKING =====
var previous_player_position: Vector2 = Vector2.ZERO
var player_velocity: Vector2 = Vector2.ZERO
var player_velocity_smooth: Vector2 = Vector2.ZERO
const PLAYER_VELOCITY_SMOOTHING: float = 5.0

# ===== ENEMY-STYLE BASICS =====
var individual_speed_multiplier: float = 1.0
var strafe_direction: float = 1.0

# ===== PERFORMANCE OPTIMIZATION =====
var distance_check_timer: float = 0.0
var cached_distance_to_player: float = 0.0
var cached_distance_to_target: float = 0.0

const DISTANCE_CHECK_INTERVAL: float = 0.1

# ===== SHIP REFERENCES =====
var owner_ship: MiniShip = null
var owner_player: Player = null
var current_state: ShipState = ShipState.PATROL_AROUND_PLAYER

var velocity: Vector2 = Vector2.ZERO
var desired_velocity: Vector2 = Vector2.ZERO
var smooth_target_position: Vector2 = Vector2.ZERO

# ===== SMOOTHING CONSTANTS =====
const ACCELERATION: float = 400.0
const ROTATION_SPEED: float = 4.0
const POSITION_SMOOTHING: float = 3.0

# ===== INITIALIZATION =====
func initialize(ship: MiniShip, player: Player) -> void:
	owner_ship = ship
	owner_player = player
	
	# Initialize player tracking
	previous_player_position = owner_player.global_position
	player_velocity = Vector2.ZERO
	player_velocity_smooth = Vector2.ZERO
	
	# Individual speed variation
	var speed_variance = 0.15
	individual_speed_multiplier = randf_range(1.0 - speed_variance, 1.0 + speed_variance)
	
	# Random initial strafe direction
	strafe_direction = 1.0 if randf() > 0.5 else -1.0
	
	# Stagger distance checks
	distance_check_timer = randf() * DISTANCE_CHECK_INTERVAL
	
	print("EnhancedShipMovement: Initialized with speed multiplier: %.2f" % individual_speed_multiplier)

# ===== MAIN UPDATE =====
func update_movement(delta: float) -> void:
	if not is_instance_valid(owner_player):
		return
	
	# ===== NEW: TRACK PLAYER MOVEMENT =====
	_update_player_velocity_tracking(delta)
	
	# Update performance caches
	_update_distance_caches(delta)
	
	# Determine state
	_update_state_machine()
	
	# Calculate movement
	_calculate_movement()
	
	# ===== NEW: ADD PLAYER-RELATIVE MOVEMENT =====
	if follow_player_movement and (current_state == ShipState.PATROL_AROUND_PLAYER or current_state == ShipState.RETURN_TO_PLAYER):
		_apply_player_relative_movement()
	
	# Apply movement with individual variation
	velocity = velocity.move_toward(desired_velocity * individual_speed_multiplier, ACCELERATION * delta)
	owner_ship.position += velocity * delta
	
	# Smooth ship rotation
	if velocity.length() > 10.0:
		var target_rotation = velocity.angle()
		owner_ship.rotation = lerp_angle(owner_ship.rotation, target_rotation, ROTATION_SPEED * delta)

# ===== NEW: PLAYER VELOCITY TRACKING =====
func _update_player_velocity_tracking(delta: float) -> void:
	"""Track player's velocity for relative movement"""
	var current_player_position = owner_player.global_position
	
	# Calculate raw player velocity
	player_velocity = (current_player_position - previous_player_position) / delta
	previous_player_position = current_player_position
	
	# Smooth the player velocity to avoid jittery movement
	player_velocity_smooth = player_velocity_smooth.lerp(player_velocity, PLAYER_VELOCITY_SMOOTHING * delta)

# ===== NEW: PLAYER-RELATIVE MOVEMENT =====
func _apply_player_relative_movement() -> void:
	"""Add player's movement to ship's desired velocity for formation flying"""
	if not follow_player_movement:
		return
	
	# Get player's movement influence
	var player_movement_influence = player_velocity_smooth * follow_responsiveness
	
	# Cap the influence to prevent excessive speeds
	if player_movement_influence.length() > follow_max_speed:
		player_movement_influence = player_movement_influence.normalized() * follow_max_speed
	
	# Add to desired velocity
	desired_velocity += player_movement_influence
	
	# Optional: Reduce base movement slightly when following to prevent over-acceleration
	if player_velocity_smooth.length() > 50.0:  # Only when player is moving meaningfully
		desired_velocity *= 0.9  # Reduce base movement by 10%

# ===== PERFORMANCE OPTIMIZATION =====
func _update_distance_caches(delta: float) -> void:
	distance_check_timer -= delta
	if distance_check_timer <= 0.0:
		distance_check_timer = DISTANCE_CHECK_INTERVAL
		cached_distance_to_player = owner_ship.global_position.distance_to(owner_player.global_position)
		
		var current_target = owner_ship.get_current_target()
		if current_target:
			cached_distance_to_target = owner_ship.global_position.distance_to(current_target.global_position)
		else:
			cached_distance_to_target = 999999.0

# ===== STATE MACHINE =====
func _update_state_machine() -> void:
	var current_target = owner_ship.get_current_target()
	
	# Return to player if too far
	if cached_distance_to_player > max_range_from_player:
		current_state = ShipState.RETURN_TO_PLAYER
		return
	
	# Strafe target if we have one and close enough to player
	if current_target and cached_distance_to_player < comfort_range:
		current_state = ShipState.STRAFE_TARGET
		return
	
	# Patrol around player otherwise
	current_state = ShipState.PATROL_AROUND_PLAYER

# ===== MOVEMENT CALCULATION =====
func _calculate_movement() -> void:
	match current_state:
		ShipState.RETURN_TO_PLAYER:
			_calculate_return_movement()
		ShipState.PATROL_AROUND_PLAYER:
			_calculate_patrol_movement()
		ShipState.STRAFE_TARGET:
			_calculate_strafe_movement()

func _calculate_return_movement() -> void:
	# Smooth approach to player with gentle offset
	var base_target = owner_player.global_position
	var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
	var target_pos = base_target + offset
	
	# Smooth the target position changes
	smooth_target_position = smooth_target_position.lerp(target_pos, POSITION_SMOOTHING * get_process_delta_time())
	var direction = (smooth_target_position - owner_ship.global_position).normalized()
	desired_velocity = direction * return_speed

func _calculate_patrol_movement() -> void:
	# Gentler patrol movement around player
	var to_player = owner_player.global_position - owner_ship.global_position
	var distance = to_player.length()
	
	if distance > comfort_range * 0.9:
		# Gentle approach to player
		desired_velocity = to_player.normalized() * patrol_speed * 0.8
	else:
		# Smooth circle around player
		var tangent = Vector2(-to_player.y, to_player.x).normalized()
		var circle_component = tangent * strafe_direction * patrol_speed * 0.6
		var inward_component = to_player.normalized() * patrol_speed * 0.3
		desired_velocity = circle_component + inward_component

func _calculate_strafe_movement() -> void:
	# Smoother strafe target (no player-relative movement when strafing)
	var current_target = owner_ship.get_current_target()
	if not current_target:
		_calculate_patrol_movement()
		return
	
	var to_target = current_target.global_position - owner_ship.global_position
	var distance = to_target.length()
	
	# Gentler range keeping
	if distance > strafe_range_outer * 1.1:
		# Smooth approach
		desired_velocity = to_target.normalized() * strafe_speed * 0.8
	elif distance < strafe_range_inner * 0.9:
		# Gentle retreat with strafe
		var away = -to_target.normalized() * strafe_speed * 0.5
		var strafe = Vector2(-to_target.y, to_target.x).normalized() * strafe_direction * strafe_speed * 0.4
		desired_velocity = away + strafe
	else:
		# Smooth strafe in optimal range
		var strafe = Vector2(-to_target.y, to_target.x).normalized() * strafe_direction
		var maintain = to_target.normalized() * 0.1
		desired_velocity = (strafe + maintain) * strafe_speed * 0.7

# ===== CONFIGURATION METHODS =====
func set_follow_player_movement(enabled: bool) -> void:
	"""Enable/disable player-relative movement"""
	follow_player_movement = enabled

func set_follow_responsiveness(responsiveness: float) -> void:
	"""Set how much ships follow player movement (0.0-1.0)"""
	follow_responsiveness = clamp(responsiveness, 0.0, 1.0)

func set_follow_max_speed(max_speed: float) -> void:
	"""Set maximum speed when following player"""
	follow_max_speed = max_speed

# ===== PUBLIC INTERFACE =====
func get_current_state() -> ShipState:
	return current_state

func get_current_state_name() -> String:
	match current_state:
		ShipState.RETURN_TO_PLAYER: return "Returning"
		ShipState.PATROL_AROUND_PLAYER: return "Patrolling"
		ShipState.STRAFE_TARGET: return "Strafing"
		_: return "Unknown"

func get_debug_info() -> Dictionary:
	var current_target = owner_ship.get_current_target()
	return {
		"state": get_current_state_name(),
		"target": current_target.name if current_target else "None",
		"velocity": velocity.length(),
		"desired_velocity": desired_velocity.length(),
		"speed_multiplier": "%.2f" % individual_speed_multiplier,
		"strafe_direction": strafe_direction,
		"distance_to_player": cached_distance_to_player,
		"follow_enabled": follow_player_movement,
		"player_velocity": "%.1f" % player_velocity_smooth.length(),
		"follow_influence": "%.1f" % (player_velocity_smooth.length() * follow_responsiveness)
	}
