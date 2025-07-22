# scripts/actors/enemys/movement/BaseRangeKeepingMovement.gd
extends BaseChaseMovement
class_name BaseRangeKeepingMovement

# ===== BASE CONFIGURATION (Override these in child classes) =====
var config_inner_range: float = 250.0
var config_outer_range: float = 300.0
var config_chase_range: float = 400.0
var config_master_interval: float = 3.0
var config_retreat_reaction_min: float = 2.0
var config_retreat_reaction_max: float = 5.0
var config_position_update_min: float = 1.0
var config_position_update_max: float = 5.0

# ===== BEHAVIOR CONFIGURATION =====
var config_strafe_intensity: float = 1.0
var config_back_away_speed: float = 1.0
var config_direction_change_slowdown: float = 0.3
var config_slowdown_duration: float = 0.5
var config_speedup_duration: float = 0.8
var config_maneuver_tracking_delay: float = 2.0

# ===== ACTION PROBABILITIES =====
var config_strafe_change_chance: float = 0.33
var config_radius_change_chance: float = 0.5
var config_stop_and_go_chance: float = 0.15
var config_stop_duration: float = 0.8
var config_acceleration_duration: float = 1.2

# ===== FIXED: DISCRETE RADIUS ZONES =====
enum RadiusZone { CLOSE, MEDIUM, FAR }
var current_radius_zone: RadiusZone = RadiusZone.MEDIUM
var zone_hysteresis: float = 0.2  # 20% buffer to prevent oscillation

# Zone-based radius targets (no more micro-adjustments)
var zone_radius_targets = {
	RadiusZone.CLOSE: 0.7,   # Stay closer
	RadiusZone.MEDIUM: 1.0,  # Default range
	RadiusZone.FAR: 1.25     # Stay farther
}

# ===== RUNTIME VARIABLES (Don't change these) =====
var strafe_direction: float = 1.0
var current_mode: String = "CHASE"
var individual_radius_multiplier: float = 1.0
var target_radius_multiplier: float = 1.0
var smooth_target_position: Vector2 = Vector2.ZERO
var tracked_player_position: Vector2 = Vector2.ZERO
var first_frame: bool = true

# ===== SPEED MODIFIERS =====
var current_speed_modifier: float = 1.0
var direction_change_active: bool = false
var stop_and_go_active: bool = false
var action_timer: float = 0.0

# ===== TRACKING TIMERS =====
var position_update_timer: float = 0.0
var position_update_interval: float = 2.0
var mode_check_timer: float = 0.0
var master_timer: float = 0.0

# ===== RETREAT SYSTEM =====
var retreat_reaction_timer: float = 0.0
var retreat_reaction_time: float = 0.0
var player_in_retreat_range: bool = false

# ===== CONSTANTS =====
const MODE_CHECK_INTERVAL: float = 0.1
const RADIUS_SMOOTHING: float = 1.5
const TARGET_SMOOTHING: float = 5.0

# ===== OVERRIDE THIS IN CHILD CLASSES =====
func configure_movement() -> void:
	"""Override this method in child classes to set custom values"""
	pass

func _on_movement_ready() -> void:
	# First, let child class configure values
	configure_movement()
	
	# Then initialize with configured values
	_initialize_radius_zone()
	individual_radius_multiplier = target_radius_multiplier
	retreat_reaction_time = randf_range(config_retreat_reaction_min, config_retreat_reaction_max)
	position_update_interval = randf_range(config_position_update_min, config_position_update_max)
	strafe_direction = 1.0 if randf() > 0.5 else -1.0
	
	# Initialize positions
	smooth_target_position = enemy.global_position
	tracked_player_position = enemy.global_position
	
	# Stagger timers
	master_timer = randf() * config_master_interval
	mode_check_timer = 0.0
	position_update_timer = 0.0

func _calculate_target_position(player: Node2D, delta: float) -> Vector2:
	# Update tracked player position
	_update_tracked_position(player, delta)
	
	# Check mode changes
	mode_check_timer -= delta
	if mode_check_timer <= 0.0:
		mode_check_timer = MODE_CHECK_INTERVAL
		_update_current_mode()
	
	# MASTER TIMER: All random actions happen here
	master_timer -= delta
	if master_timer <= 0.0:
		master_timer = config_master_interval
		_execute_random_actions()
	
	# Handle active speed modifiers
	_update_speed_modifiers(delta)
	
	# FIXED: Update radius zones instead of continuous adjustments
	_update_radius_zones()
	
	# Smooth radius changes
	individual_radius_multiplier = lerp(individual_radius_multiplier, target_radius_multiplier, RADIUS_SMOOTHING * delta)
	
	# Calculate target based on mode
	var calculated_target = _get_mode_target(player)
	
	# Smooth the target position
	smooth_target_position = smooth_target_position.lerp(calculated_target, TARGET_SMOOTHING * delta)
	return smooth_target_position

# ===== FIXED: DISCRETE ZONE SYSTEM =====
func _initialize_radius_zone() -> void:
	"""Initialize starting radius zone"""
	current_radius_zone = RadiusZone.MEDIUM
	target_radius_multiplier = zone_radius_targets[current_radius_zone]

func _update_radius_zones() -> void:
	"""Update radius zones with hysteresis to prevent jitter"""
	var distance = get_cached_distance_to_player()
	var inner_threshold = config_inner_range * individual_radius_multiplier
	var outer_threshold = config_outer_range * individual_radius_multiplier
	
	# Zone transitions with hysteresis buffers
	match current_radius_zone:
		RadiusZone.CLOSE:
			# Need significant distance before switching to MEDIUM
			if distance > inner_threshold * (1.0 + zone_hysteresis):
				current_radius_zone = RadiusZone.MEDIUM
				target_radius_multiplier = zone_radius_targets[RadiusZone.MEDIUM]
		
		RadiusZone.MEDIUM:
			# Check for transitions to either CLOSE or FAR
			if distance < inner_threshold * (1.0 - zone_hysteresis):
				current_radius_zone = RadiusZone.CLOSE
				target_radius_multiplier = zone_radius_targets[RadiusZone.CLOSE]
			elif distance > outer_threshold * (1.0 + zone_hysteresis):
				current_radius_zone = RadiusZone.FAR
				target_radius_multiplier = zone_radius_targets[RadiusZone.FAR]
		
		RadiusZone.FAR:
			# Need to get significantly closer before switching to MEDIUM
			if distance < outer_threshold * (1.0 - zone_hysteresis):
				current_radius_zone = RadiusZone.MEDIUM
				target_radius_multiplier = zone_radius_targets[RadiusZone.MEDIUM]

func _execute_random_actions() -> void:
	# Roll dice for each possible action
	var roll = randf()
	
	# Stop-and-go has highest priority
	if roll < config_stop_and_go_chance and not stop_and_go_active and not direction_change_active:
		_start_stop_and_go()
		return
	
	# Strafe direction change (only in maneuver mode)
	roll = randf()
	if current_mode == "MANEUVER" and roll < config_strafe_change_chance and not direction_change_active and not stop_and_go_active:
		_start_direction_change()
	
	# REMOVED: No more random radius changes - zones handle this automatically

func _start_stop_and_go() -> void:
	stop_and_go_active = true
	action_timer = 0.0

func _start_direction_change() -> void:
	strafe_direction *= -1.0
	direction_change_active = true
	action_timer = 0.0

func _update_speed_modifiers(delta: float) -> void:
	if stop_and_go_active:
		action_timer += delta
		var total_duration = config_stop_duration + config_acceleration_duration
		
		if action_timer >= total_duration:
			stop_and_go_active = false
			current_speed_modifier = 1.0
		elif action_timer <= config_stop_duration:
			var progress = action_timer / config_stop_duration
			current_speed_modifier = lerp(1.0, 0.0, progress)
		else:
			var accel_progress = (action_timer - config_stop_duration) / config_acceleration_duration
			current_speed_modifier = lerp(0.0, 1.0, accel_progress)
	
	elif direction_change_active:
		action_timer += delta
		var total_duration = config_slowdown_duration + config_speedup_duration
		
		if action_timer >= total_duration:
			direction_change_active = false
			current_speed_modifier = 1.0
		elif action_timer <= config_slowdown_duration:
			var progress = action_timer / config_slowdown_duration
			current_speed_modifier = lerp(1.0, config_direction_change_slowdown, progress)
		else:
			var speedup_progress = (action_timer - config_slowdown_duration) / config_speedup_duration
			current_speed_modifier = lerp(config_direction_change_slowdown, 1.0, speedup_progress)
	
	else:
		current_speed_modifier = 1.0

func _update_tracked_position(player: Node2D, delta: float) -> void:
	if first_frame:
		tracked_player_position = player.global_position
		position_update_timer = position_update_interval
		first_frame = false
		return
	
	position_update_timer -= delta
	if position_update_timer <= 0.0:
		tracked_player_position = player.global_position
		position_update_timer = position_update_interval if current_mode == "MANEUVER" else position_update_interval * 0.3

func _update_current_mode() -> void:
	var distance = get_cached_distance_to_player()
	var scaled_inner = config_inner_range * individual_radius_multiplier
	var scaled_outer = config_outer_range * individual_radius_multiplier
	var scaled_chase = config_chase_range * individual_radius_multiplier
	
	# Update retreat trigger state
	var was_in_retreat_range = player_in_retreat_range
	player_in_retreat_range = distance < scaled_inner
	
	# Handle retreat reaction timing
	if player_in_retreat_range and not was_in_retreat_range:
		retreat_reaction_timer = retreat_reaction_time
	elif player_in_retreat_range:
		retreat_reaction_timer -= get_process_delta_time()
	elif not player_in_retreat_range:
		retreat_reaction_timer = 0.0
	
	# Determine mode
	if distance > scaled_chase:
		current_mode = "CHASE"
	elif player_in_retreat_range and retreat_reaction_timer <= 0.0:
		current_mode = "RETREAT"
	elif distance < scaled_outer and not player_in_retreat_range:
		current_mode = "MANEUVER"
	else:
		current_mode = "MANEUVER"

func _get_mode_target(player: Node2D) -> Vector2:
	match current_mode:
		"CHASE":
			return tracked_player_position
		"MANEUVER":
			return _calculate_maneuver_target()
		"RETREAT":
			return _calculate_retreat_target()
		_:
			return player.global_position

func _calculate_maneuver_target() -> Vector2:
	var to_player = tracked_player_position - enemy.global_position
	var scaled_outer_range = config_outer_range * individual_radius_multiplier
	
	# Perpendicular vector for strafing
	var perp = Vector2(-to_player.y, to_player.x).normalized()
	var strafe_offset = perp * strafe_direction * config_strafe_intensity * 50.0
	
	# Maintain distance point
	var maintain_distance_point = tracked_player_position - to_player.normalized() * scaled_outer_range
	return maintain_distance_point + strafe_offset

func _calculate_retreat_target() -> Vector2:
	var to_player = tracked_player_position - enemy.global_position
	var away_from_player = -to_player.normalized()
	var retreat_distance = 100.0 * individual_radius_multiplier
	
	# Add strafe component
	var perp = Vector2(-to_player.y, to_player.x).normalized()
	var strafe_offset = perp * strafe_direction * config_strafe_intensity * 30.0
	
	var retreat_point = enemy.global_position + away_from_player * retreat_distance
	return retreat_point + strafe_offset

func _get_speed_multiplier() -> float:
	return current_speed_modifier

# ===== PUBLIC GETTERS =====
func get_current_mode() -> String:
	return current_mode

func get_current_speed_multiplier() -> float:
	return current_speed_modifier

func get_current_radius_zone() -> String:
	"""NEW: Get current radius zone for debugging"""
	match current_radius_zone:
		RadiusZone.CLOSE: return "CLOSE"
		RadiusZone.MEDIUM: return "MEDIUM"
		RadiusZone.FAR: return "FAR"
		_: return "UNKNOWN"
