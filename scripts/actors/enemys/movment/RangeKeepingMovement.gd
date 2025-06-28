# RANGE-KEEPING MOVEMENT SYSTEM (OPTIMIZED)
# ==========================================
# Single master timer system with probability-based actions
# Cleaner code structure with same behavior
#
# SPAWN FIX: Enemies now immediately see player on first frame to prevent
# going to screen center. After that, they become "dumber" with delayed updates.

extends BaseChaseMovement
class_name RangeKeepingMovement

# ===== RANGE-KEEPING CONTROLS =====
@export var inner_range: float = 250.0      
@export var outer_range: float = 300.0      
@export var chase_range: float = 400.0      
@export var strafe_intensity: float = 1.0   
@export var back_away_speed: float = 1.0    

# ===== DIRECTION CHANGE SLOWDOWN =====
@export var direction_change_slowdown: float = 0.3  
@export var slowdown_duration: float = 0.5          
@export var speedup_duration: float = 0.8           

# ===== PLAYER TRACKING DELAY =====
@export var position_update_interval_min: float = 1.0  
@export var position_update_interval_max: float = 5.0  
@export var maneuver_tracking_delay: float = 2.0       

# ===== ACTION PROBABILITIES (every 3 seconds) =====
@export var strafe_change_chance: float = 0.33      # 33% chance to change strafe direction
@export var radius_change_chance: float = 0.5       # 50% chance to change radius
@export var stop_and_go_chance: float = 0.15        # 15% chance for stop-and-go maneuver
@export var stop_duration: float = 0.8               # How long to stop (seconds)
@export var acceleration_duration: float = 1.2       # How long to accelerate back (seconds)

# ===== MASTER TIMER =====
const MASTER_INTERVAL: float = 3.0                   # Check all actions every 3 seconds
var master_timer: float = 0.0                        

# ===== STATE VARIABLES =====
var strafe_direction: float = 1.0           
var current_mode: String = "CHASE"          
var individual_radius_multiplier: float = 1.0  
var target_radius_multiplier: float = 1.0      
var smooth_target_position: Vector2 = Vector2.ZERO  
var tracked_player_position: Vector2 = Vector2.ZERO  
var first_frame: bool = true  # Track if this is the first update  

# ===== SPEED MODIFIERS =====
var current_speed_modifier: float = 1.0              # Combined speed modifier
var direction_change_active: bool = false            # Is direction change happening?
var stop_and_go_active: bool = false                 # Is stop-and-go happening?
var action_timer: float = 0.0                        # Timer for current action

# ===== TRACKING TIMERS =====
var position_update_timer: float = 0.0               
var position_update_interval: float = 2.0            
var mode_check_timer: float = 0.0           

# ===== RETREAT SYSTEM =====
var retreat_reaction_timer: float = 0.0     
var retreat_reaction_time: float = 0.0      
var player_in_retreat_range: bool = false   

# ===== CONSTANTS =====
const MODE_CHECK_INTERVAL: float = 0.1      
const RADIUS_MIN_MULTIPLIER: float = 0.4    
const RADIUS_MAX_MULTIPLIER: float = 1.3    
const RADIUS_SMOOTHING: float = 1.5         
const TARGET_SMOOTHING: float = 5.0         
const RETREAT_REACTION_MIN: float = 2.0    
const RETREAT_REACTION_MAX: float = 5.0     

func _on_movement_ready() -> void:
	# Initialize individual values
	_randomize_radius_target()
	individual_radius_multiplier = target_radius_multiplier
	retreat_reaction_time = randf_range(RETREAT_REACTION_MIN, RETREAT_REACTION_MAX)
	position_update_interval = randf_range(position_update_interval_min, position_update_interval_max)
	strafe_direction = 1.0 if randf() > 0.5 else -1.0
	
	# Initialize positions
	smooth_target_position = enemy.global_position
	tracked_player_position = enemy.global_position  # Will be updated on first frame
	
	# ALTERNATIVE: If you have access to player reference here, you can do:
	# if has_method("find_player"):
	#     var player = find_player()  # or whatever your method is called
	#     if player:
	#         tracked_player_position = player.global_position
	
	# Stagger timers
	master_timer = randf() * MASTER_INTERVAL
	mode_check_timer = 0.0  # Immediate first mode check
	position_update_timer = 0.0  # Force immediate player position update on first frame

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
		master_timer = MASTER_INTERVAL
		_execute_random_actions()
	
	# Handle active speed modifiers
	_update_speed_modifiers(delta)
	
	# Smooth radius changes
	individual_radius_multiplier = lerp(individual_radius_multiplier, target_radius_multiplier, RADIUS_SMOOTHING * delta)
	
	# Calculate target based on mode
	var calculated_target = _get_mode_target(player)
	
	# Smooth the target position
	smooth_target_position = smooth_target_position.lerp(calculated_target, TARGET_SMOOTHING * delta)
	return smooth_target_position

func _execute_random_actions() -> void:
	# Roll dice for each possible action
	var roll = randf()
	
	# Stop-and-go has highest priority (15% chance)
	if roll < stop_and_go_chance and not stop_and_go_active and not direction_change_active:
		_start_stop_and_go()
		return  # Only one action at a time
	
	# Strafe direction change (33% chance, only in maneuver mode)
	roll = randf()
	if current_mode == "MANEUVER" and roll < strafe_change_chance and not direction_change_active and not stop_and_go_active:
		_start_direction_change()
	
	# Radius change (50% chance)
	roll = randf()
	if roll < radius_change_chance:
		_randomize_radius_target()

func _start_stop_and_go() -> void:
	stop_and_go_active = true
	action_timer = 0.0
	print("Enemy starting stop-and-go maneuver!")

func _start_direction_change() -> void:
	strafe_direction *= -1.0
	direction_change_active = true
	action_timer = 0.0
	print("Enemy changed strafe direction - slowing down!")

func _update_speed_modifiers(delta: float) -> void:
	if stop_and_go_active:
		action_timer += delta
		var total_duration = stop_duration + acceleration_duration
		
		if action_timer >= total_duration:
			# Action complete
			stop_and_go_active = false
			current_speed_modifier = 1.0
		elif action_timer <= stop_duration:
			# Stopping phase
			var progress = action_timer / stop_duration
			current_speed_modifier = lerp(1.0, 0.0, progress)
		else:
			# Accelerating phase
			var accel_progress = (action_timer - stop_duration) / acceleration_duration
			current_speed_modifier = lerp(0.0, 1.0, accel_progress)
	
	elif direction_change_active:
		action_timer += delta
		var total_duration = slowdown_duration + speedup_duration
		
		if action_timer >= total_duration:
			# Action complete
			direction_change_active = false
			current_speed_modifier = 1.0
		elif action_timer <= slowdown_duration:
			# Slowing down phase
			var progress = action_timer / slowdown_duration
			current_speed_modifier = lerp(1.0, direction_change_slowdown, progress)
		else:
			# Speeding up phase
			var speedup_progress = (action_timer - slowdown_duration) / speedup_duration
			current_speed_modifier = lerp(direction_change_slowdown, 1.0, speedup_progress)
	
	else:
		# No active speed modifier
		current_speed_modifier = 1.0

func _update_tracked_position(player: Node2D, delta: float) -> void:
	# First frame: always update immediately
	if first_frame:
		tracked_player_position = player.global_position
		position_update_timer = position_update_interval
		first_frame = false
		return
	
	# Normal operation: update on timer
	position_update_timer -= delta
	if position_update_timer <= 0.0:
		tracked_player_position = player.global_position
		# Different update rates for different modes
		position_update_timer = position_update_interval if current_mode == "MANEUVER" else position_update_interval * 0.3

func _update_current_mode() -> void:
	var distance = get_cached_distance_to_player()
	var scaled_inner = inner_range * individual_radius_multiplier
	var scaled_outer = outer_range * individual_radius_multiplier
	var scaled_chase = chase_range * individual_radius_multiplier
	
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
	var scaled_outer_range = outer_range * individual_radius_multiplier
	
	# Perpendicular vector for strafing
	var perp = Vector2(-to_player.y, to_player.x).normalized()
	var strafe_offset = perp * strafe_direction * strafe_intensity * 50.0
	
	# Maintain distance point
	var maintain_distance_point = tracked_player_position - to_player.normalized() * scaled_outer_range
	return maintain_distance_point + strafe_offset

func _calculate_retreat_target() -> Vector2:
	var to_player = tracked_player_position - enemy.global_position
	var away_from_player = -to_player.normalized()
	var retreat_distance = 100.0 * individual_radius_multiplier
	
	# Add strafe component
	var perp = Vector2(-to_player.y, to_player.x).normalized()
	var strafe_offset = perp * strafe_direction * strafe_intensity * 30.0
	
	var retreat_point = enemy.global_position + away_from_player * retreat_distance
	return retreat_point + strafe_offset

func _randomize_radius_target() -> void:
	# 60% larger, 40% smaller radius bias
	if randf() < 0.6:
		target_radius_multiplier = randf_range(0.85, RADIUS_MAX_MULTIPLIER)
	else:
		target_radius_multiplier = randf_range(RADIUS_MIN_MULTIPLIER, 0.85)

func _get_speed_multiplier() -> float:
	return current_speed_modifier

# ===== PUBLIC GETTERS =====
func get_current_mode() -> String:
	return current_mode

func get_current_speed_multiplier() -> float:
	return current_speed_modifier
