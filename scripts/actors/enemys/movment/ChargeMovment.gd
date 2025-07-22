# scripts/actors/enemys/movement/ChargeMovement.gd
extends BaseChaseMovement
class_name ChargeMovement

# ===== CHARGE CONFIGURATION =====
@export var charge_range: float = 250.0        # How close to trigger charge
@export var charge_distance_multiplier: float = 4.0  # How far past player to charge (was 2.5)
@export var charge_acceleration: float = 800.0 # How fast to accelerate during charge
@export var max_charge_speed: float = 400.0    # Max speed during charge
@export var charge_cooldown: float = 0.8       # Seconds between charges (was 3.0)

# ===== CHARGE STATE =====
enum ChargeState { NORMAL_CHASE, CHARGING, COOLDOWN }
var current_state: ChargeState = ChargeState.NORMAL_CHASE
var charge_target: Vector2 = Vector2.ZERO
var charge_speed: float = 0.0
var cooldown_timer: float = 0.0

# ===== CHARGE DETECTION =====
var range_check_timer: float = 0.0
const RANGE_CHECK_INTERVAL: float = 0.1

func _on_movement_ready() -> void:
	# Stagger the range check timer
	range_check_timer = randf() * RANGE_CHECK_INTERVAL

func _calculate_target_position(player: Node2D, delta: float) -> Vector2:
	# Update charge state machine
	_update_charge_state(player, delta)
	
	# Calculate movement based on current state
	match current_state:
		ChargeState.NORMAL_CHASE:
			return _normal_chase_movement(player)
		ChargeState.CHARGING:
			return _charge_movement(delta)
		ChargeState.COOLDOWN:
			return _cooldown_movement(player)
		_:
			return player.global_position

func _update_charge_state(player: Node2D, delta: float) -> void:
	match current_state:
		ChargeState.NORMAL_CHASE:
			_check_for_charge_opportunity(player, delta)
		
		ChargeState.CHARGING:
			_update_charging(delta)
		
		ChargeState.COOLDOWN:
			cooldown_timer -= delta
			if cooldown_timer <= 0.0:
				current_state = ChargeState.NORMAL_CHASE

func _check_for_charge_opportunity(player: Node2D, delta: float) -> void:
	# Only check range periodically for performance
	range_check_timer -= delta
	if range_check_timer <= 0.0:
		range_check_timer = RANGE_CHECK_INTERVAL
		
		var distance = enemy.global_position.distance_to(player.global_position)
		if distance <= charge_range:
			_start_charge(player)

func _start_charge(player: Node2D) -> void:
	current_state = ChargeState.CHARGING
	
	# Calculate charge target: player position + extended vector
	var to_player = player.global_position - enemy.global_position
	var charge_direction = to_player.normalized()
	
	# FIXED: Charge distance based on charge_range (150px), not current distance to player
	var extended_distance = charge_range * charge_distance_multiplier  # 150 * 4.0 = 600px always
	
	charge_target = enemy.global_position + (charge_direction * extended_distance)
	charge_speed = enemy.speed  # Start with normal speed
	
	print("Tank charging! Distance: ", extended_distance, " Target: ", charge_target)

func _update_charging(delta: float) -> void:
	# Check if we've reached the charge target
	var distance_to_target = enemy.global_position.distance_to(charge_target)
	
	if distance_to_target < 20.0:  # Close enough to target
		_end_charge()
		return
	
	# Accelerate towards max charge speed
	charge_speed = min(charge_speed + charge_acceleration * delta, max_charge_speed)

func _end_charge() -> void:
	current_state = ChargeState.COOLDOWN
	cooldown_timer = charge_cooldown
	charge_speed = enemy.speed  # Reset to normal speed
	print("Tank charge complete, entering cooldown")

func _normal_chase_movement(player: Node2D) -> Vector2:
	# Standard chase behavior - just move toward player
	return player.global_position

func _charge_movement(delta: float) -> Vector2:
	# Move toward charge target at charge speed
	return charge_target

func _cooldown_movement(player: Node2D) -> Vector2:
	# During cooldown, move slowly toward player
	return player.global_position

func _get_speed_multiplier() -> float:
	match current_state:
		ChargeState.NORMAL_CHASE:
			return 1.0  # Normal speed
		ChargeState.CHARGING:
			return charge_speed / enemy.speed  # Use charge speed
		ChargeState.COOLDOWN:
			return 0.6  # Slower during cooldown
		_:
			return 1.0

# ===== PUBLIC GETTERS FOR DEBUGGING =====
func get_current_state() -> String:
	match current_state:
		ChargeState.NORMAL_CHASE:
			return "CHASE"
		ChargeState.CHARGING:
			return "CHARGING"
		ChargeState.COOLDOWN:
			return "COOLDOWN"
		_:
			return "UNKNOWN"

func get_cooldown_remaining() -> float:
	return cooldown_timer if current_state == ChargeState.COOLDOWN else 0.0
