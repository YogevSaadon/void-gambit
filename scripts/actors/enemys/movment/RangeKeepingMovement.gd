# RANGE-KEEPING MOVEMENT SYSTEM
# ================================
# For tactical enemies that maintain optimal shooting distance
# Inherits speed variation and performance optimizations from BaseChaseMovement
# Behavior: Chase → Maneuver in optimal range → Retreat if too close

extends BaseChaseMovement
class_name RangeKeepingMovement

# ===== RANGE-KEEPING CONTROLS =====
@export var inner_range: float = 250.0      # Too close - back away
@export var outer_range: float = 300.0      # Optimal shooting range
@export var chase_range: float = 400.0      # Return to chase beyond this
@export var strafe_intensity: float = 1.0   # How much side-to-side movement
@export var back_away_speed: float = 1.0    # Speed multiplier when retreating (same as normal)

# ===== INDIVIDUAL RADIUS VARIATION =====
var individual_radius_multiplier: float = 1.0  # Each enemy gets unique radius preference
var target_radius_multiplier: float = 1.0      # Target radius we're lerping toward
var radius_change_timer: float = 0.0           # Timer for changing preferred radius

# ===== RANGE-KEEPING STATE =====
var strafe_direction: float = 1.0           # 1.0 = right, -1.0 = left
var strafe_switch_timer: float = 0.0        # Timer for possible direction changes
var current_mode: String = "CHASE"          # CHASE, MANEUVER, RETREAT

# ===== RETREAT DELAY SYSTEM =====
var retreat_reaction_timer: float = 0.0     # Timer before actually retreating
var retreat_reaction_time: float = 0.0      # Randomized reaction time for this enemy
var player_in_retreat_range: bool = false   # Is player close enough to trigger retreat?

# ===== SMOOTH MOVEMENT =====
var smooth_target_position: Vector2 = Vector2.ZERO  # Smoothed target position

# ===== PERFORMANCE TIMERS =====
var mode_check_timer: float = 0.0           # Prevents excessive mode switching

# ===== CONSTANTS =====
const MODE_CHECK_INTERVAL: float = 0.1      # Check mode every 0.1 seconds
const STRAFE_CHECK_INTERVAL: float = 3.0    # Check for direction change every 3 seconds
const DIRECTION_CHANGE_CHANCE: float = 0.33  # 33% chance to change direction (2:1 odds against)
const RADIUS_CHANGE_INTERVAL: float = 3.0   # Change preferred radius every 3 seconds
const RADIUS_MIN_MULTIPLIER: float = 0.6    # -40% minimum radius
const RADIUS_MAX_MULTIPLIER: float = 1.3    # +30% maximum radius
const RADIUS_SMOOTHING: float = 1.5         # How fast to lerp radius changes
const TARGET_SMOOTHING: float = 5.0         # How fast to smooth target position changes
const RETREAT_REACTION_MIN: float = 2.0    # Minimum retreat reaction time
const RETREAT_REACTION_MAX: float = 3.0     # Maximum retreat reaction time

func _on_movement_ready() -> void:
	# INITIAL RADIUS VARIATION: Each enemy starts with radius in range
	_randomize_radius_target()
	individual_radius_multiplier = target_radius_multiplier  # Start at target
	
	# RANDOMIZE RETREAT REACTION TIME: Each enemy has different reaction speed
	retreat_reaction_time = randf_range(RETREAT_REACTION_MIN, RETREAT_REACTION_MAX)
	
	# Initialize strafe direction randomly
	strafe_direction = 1.0 if randf() > 0.5 else -1.0
	
	# Initialize smooth target position
	smooth_target_position = enemy.global_position
	
	# Stagger performance timers
	mode_check_timer = randf() * MODE_CHECK_INTERVAL
	strafe_switch_timer = randf() * STRAFE_CHECK_INTERVAL
	radius_change_timer = randf() * RADIUS_CHANGE_INTERVAL

func _calculate_target_position(player: Node2D, delta: float) -> Vector2:
	# OPTIMIZATION: Only check mode changes on intervals
	mode_check_timer -= delta
	if mode_check_timer <= 0.0:
		mode_check_timer = MODE_CHECK_INTERVAL
		_update_current_mode()
	
	# Handle POSSIBLE strafe direction changes (only in maneuver mode)
	if current_mode == "MANEUVER":
		strafe_switch_timer -= delta
		if strafe_switch_timer <= 0.0:
			strafe_switch_timer = STRAFE_CHECK_INTERVAL  # Reset timer
			# RANDOM CHANCE to change direction (not guaranteed!)
			if randf() < DIRECTION_CHANGE_CHANCE:
				strafe_direction *= -1.0
				print("Enemy changed strafe direction!")
	
	# Handle DYNAMIC radius changes every 3 seconds
	radius_change_timer -= delta
	if radius_change_timer <= 0.0:
		radius_change_timer = RADIUS_CHANGE_INTERVAL
		_randomize_radius_target()
		print("Enemy changing radius target to: ", target_radius_multiplier)
	
	# GRADUALLY change radius toward target
	individual_radius_multiplier = lerp(individual_radius_multiplier, target_radius_multiplier, RADIUS_SMOOTHING * delta)
	
	# Calculate the raw target position based on current mode
	var calculated_target: Vector2
	match current_mode:
		"CHASE":
			calculated_target = _chase_movement(player)
		"MANEUVER":
			calculated_target = _maneuver_movement(player)
		"RETREAT":
			calculated_target = _retreat_movement(player)
		_:
			calculated_target = player.global_position  # Fallback
	
	# SMOOTH the target position instead of applying sharp changes
	smooth_target_position = smooth_target_position.lerp(calculated_target, TARGET_SMOOTHING * delta)
	return smooth_target_position

func _update_current_mode() -> void:
	var distance = get_cached_distance_to_player()
	
	# Apply individual radius scaling to all range checks
	var scaled_inner = inner_range * individual_radius_multiplier
	var scaled_outer = outer_range * individual_radius_multiplier
	var scaled_chase = chase_range * individual_radius_multiplier
	
	# Check if player is in retreat trigger range
	var was_in_retreat_range = player_in_retreat_range
	player_in_retreat_range = distance < scaled_inner
	
	# Handle retreat reaction timing
	if player_in_retreat_range and not was_in_retreat_range:
		# Player just entered retreat range - start reaction timer
		retreat_reaction_timer = retreat_reaction_time
		print("Enemy detected close player - reaction time: ", retreat_reaction_time)
	elif player_in_retreat_range:
		# Player still in retreat range - count down reaction timer
		retreat_reaction_timer -= get_process_delta_time()
	elif not player_in_retreat_range:
		# Player moved away - reset reaction timer
		retreat_reaction_timer = 0.0
	
	# DETERMINE MODE: Immediate for chase/maneuver, delayed for retreat
	if distance > scaled_chase:
		current_mode = "CHASE"
	elif player_in_retreat_range and retreat_reaction_timer <= 0.0:
		current_mode = "RETREAT"  # Only retreat after reaction time
	elif distance < scaled_outer and not player_in_retreat_range:
		current_mode = "MANEUVER"
	else:
		# Default: maneuver if we're not retreating yet
		current_mode = "MANEUVER"

func _chase_movement(player: Node2D) -> Vector2:
	# Direct chase - move straight toward player
	return player.global_position

func _maneuver_movement(player: Node2D) -> Vector2:
	# OPTIMAL RANGE: Circle strafe around player
	var to_player = player.global_position - enemy.global_position
	var distance = to_player.length()
	
	# Apply individual radius scaling to this enemy's preferred range
	var scaled_outer_range = outer_range * individual_radius_multiplier
	
	# Calculate perpendicular vector for strafing
	var perp = Vector2(-to_player.y, to_player.x).normalized()
	var strafe_offset = perp * strafe_direction * strafe_intensity * 50.0
	
	# Target a point that maintains THIS enemy's preferred distance
	var maintain_distance_point = player.global_position - to_player.normalized() * scaled_outer_range
	return maintain_distance_point + strafe_offset

func _retreat_movement(player: Node2D) -> Vector2:
	# TOO CLOSE: Back away from player while maintaining some strafe
	var to_player = player.global_position - enemy.global_position
	var away_from_player = -to_player.normalized()
	
	# Apply individual radius scaling for retreat distance
	var retreat_distance = 100.0 * individual_radius_multiplier
	
	# Add some strafe component to make retreat less predictable
	var perp = Vector2(-to_player.y, to_player.x).normalized()
	var strafe_offset = perp * strafe_direction * strafe_intensity * 30.0
	
	# Target a point that's backing away but with some side movement
	var retreat_point = enemy.global_position + away_from_player * retreat_distance
	return retreat_point + strafe_offset

func _get_speed_multiplier() -> float:
	# CONSISTENT SPEED: No speed variations for any mode
	return 1.0

# ===== RADIUS MANAGEMENT =====
func _randomize_radius_target() -> void:
	# Generate new radius target: +10% to -40%
	target_radius_multiplier = randf_range(RADIUS_MIN_MULTIPLIER, RADIUS_MAX_MULTIPLIER)

# ===== DEBUG HELPER (optional) =====
func get_current_mode() -> String:
	return current_mode
