# SAWBLADE MOVEMENT SYSTEM  
# =========================
# For enemies that orbit through player for contact damage (like spinning sawblades)
# Inherits speed variation and performance optimizations from BaseChaseMovement
# Adds: cloud formations, orbital sawblade behavior

extends BaseChaseMovement
class_name SawbladeMovement

# ===== SAWBLADE-SPECIFIC CONTROLS =====
@export var cloud_size: float = 1.0          # SIZE: 0.5=small cloud, 1.0=normal, 2.0=big cloud
@export var cloud_tightness: float = 1.0     # DENSITY: 0.5=loose/spread, 1.0=normal, 2.0=tight/aggressive
@export var orbit_radius: float = 15.0       # SAWBLADE SIZE: How close enemies orbit (contact damage circle)
@export var orbit_switch_chance: float = 0.02 # How often orbital enemies change direction (chaos level)

# ===== SAWBLADE STATE VARIABLES =====
var overshoot_offset: Vector2 = Vector2.ZERO  # Where enemy targets past player (creates circulation)
var approach_angle: float = 0.0               # Direction of approach/circulation

# ===== ORBITAL BEHAVIOR VARIABLES =====
var orbit_direction: float = 1.0     # 1.0 = clockwise, -1.0 = counterclockwise
var orbit_angle: float = 0.0         # Current position in circular orbit
var in_orbit_mode: bool = false      # TRUE = sawblade mode, FALSE = approach mode

# ===== SAWBLADE PERFORMANCE TIMERS =====
var direction_switch_timer: float = 0.0      # Timer for random direction changes
var mode_switch_timer: float = 0.0           # Timer for mode switching checks (FIXES FPS SPIKE)

# ===== SAWBLADE ALGORITHM CONSTANTS =====
const BASE_OVERSHOOT_DISTANCE: float = 35.0  # Base circulation radius
const BASE_TURN_TRIGGER_DISTANCE: float = 30.0 # When to change direction
const BASE_MIN_ANGLE: float = PI * 0.5        # Minimum turn angle (90 degrees)
const BASE_MAX_ANGLE: float = PI * 1.5        # Maximum turn angle (270 degrees)

# ===== SAWBLADE PERFORMANCE INTERVALS =====
const DIRECTION_CHECK_INTERVAL: float = 0.5   # Check direction switch every 0.5 seconds
const MODE_SWITCH_CHECK_INTERVAL: float = 0.05 # Check mode transitions (PREVENTS MASS SWITCHING)

# OVERRIDE: Initialize sawblade-specific behavior
func _on_movement_ready() -> void:
	# RANDOM INITIAL VALUES: Prevents synchronized behavior
	orbit_direction = 1.0 if randf() > 0.5 else -1.0  # Random orbit direction
	orbit_angle = randf() * TAU                        # Random starting orbit position
	approach_angle = randf() * TAU                     # Random approach direction
	
	_update_overshoot_offset()
	
	# STAGGER SAWBLADE TIMERS: Prevents all enemies from calculating simultaneously
	direction_switch_timer = randf() * DIRECTION_CHECK_INTERVAL
	mode_switch_timer = randf() * MODE_SWITCH_CHECK_INTERVAL

func _update_overshoot_offset() -> void:
	# CLOUD SIZE SCALING: Bigger cloud_size = wider circulation patterns
	var max_distance = BASE_OVERSHOOT_DISTANCE * cloud_size
	
	# CLOUD TIGHTNESS EFFECT: Controls how close enemies can get to center
	# tightness=0.5: enemies can get very close to center (loose cloud)
	# tightness=2.0: enemies stay toward outer edge (tight/aggressive cloud)
	var base_min_percentage = 0.3  # 30% default minimum distance
	var tightness_adjusted_min = base_min_percentage + (cloud_tightness - 1.0) * 0.3
	tightness_adjusted_min = clamp(tightness_adjusted_min, 0.1, 0.8)  # Keep reasonable bounds
	
	# RANDOM DISTANCE WITHIN RANGE: Fills the cloud instead of creating empty rings
	var min_distance = max_distance * tightness_adjusted_min
	var random_distance = randf_range(min_distance, max_distance)
	
	# SET OVERSHOOT TARGET: Enemy targets this point PAST the player
	overshoot_offset = Vector2(cos(approach_angle), sin(approach_angle)) * random_distance

# OVERRIDE: Calculate target position based on sawblade behavior
func _calculate_target_position(player: Node2D, delta: float) -> Vector2:
	# FIX: STAGGERED MODE SWITCHING - Prevents mass mode changes causing FPS spikes
	mode_switch_timer -= delta
	if mode_switch_timer <= 0.0:
		mode_switch_timer = MODE_SWITCH_CHECK_INTERVAL
		
		# MODE DECISION: Close = sawblade orbital, Far = approach circulation
		var distance = get_cached_distance_to_player()
		if distance <= orbit_radius * 2.5:
			in_orbit_mode = true
		else:
			in_orbit_mode = false
	
	# EXECUTE MOVEMENT: Based on current mode
	if in_orbit_mode:
		return _calculate_orbital_target(player, delta)
	else:
		return _calculate_approach_target(player, delta)

func _calculate_orbital_target(player: Node2D, delta: float) -> Vector2:
	# SAWBLADE ORBITAL MODE: Enemies orbit THROUGH player for contact damage
	# Like a spinning sawblade that cuts as it rotates
	
	# OPTIMIZATION: Reduce random direction switch checks (expensive)
	direction_switch_timer -= delta
	if direction_switch_timer <= 0.0:
		direction_switch_timer = DIRECTION_CHECK_INTERVAL
		# Adjust probability for the check interval (maintain same effective rate)
		if randf() < orbit_switch_chance * DIRECTION_CHECK_INTERVAL * 60.0:
			orbit_direction *= -1.0  # Reverse orbit direction for unpredictability
	
	# ORBITAL MOTION CALCULATION
	var final_speed = enemy.speed * speed_scale * individual_speed_multiplier
	var orbit_speed = final_speed / orbit_radius  # Convert linear speed to angular speed
	orbit_angle += orbit_speed * orbit_direction * delta
	
	# TARGET POSITION: Point on circle that OVERLAPS with player
	# orbit_radius is small enough that enemies pass THROUGH player collision area
	var orbit_offset = Vector2(cos(orbit_angle), sin(orbit_angle)) * orbit_radius
	return player.global_position + orbit_offset

func _calculate_approach_target(player: Node2D, delta: float) -> Vector2:
	# APPROACH/CIRCULATION MODE: Flowing cloud formations when far from player
	# Uses overshoot targeting to create beautiful circulation patterns
	
	var target_position = player.global_position + overshoot_offset
	
	# CIRCULATION BEHAVIOR: When enemy reaches overshoot target, pick new direction
	var turn_frequency_multiplier = cloud_tightness  # Tighter clouds turn more often
	var scaled_turn_distance = BASE_TURN_TRIGGER_DISTANCE * cloud_size / turn_frequency_multiplier
	var distance_to_target = enemy.global_position.distance_to(target_position)
	
	if distance_to_target < scaled_turn_distance:
		# TURN ANGLE CALCULATION: Tighter clouds = bigger angle changes (more chaotic)
		var angle_scale_factor = cloud_tightness / cloud_size
		var min_angle = BASE_MIN_ANGLE * angle_scale_factor
		var max_angle = BASE_MAX_ANGLE * angle_scale_factor
		
		var angle_change = randf_range(min_angle, max_angle)
		approach_angle += angle_change
		_update_overshoot_offset()  # Generate new circulation target
	
	return target_position
