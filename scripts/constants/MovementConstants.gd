# scripts/constants/MovementConstants.gd
class_name MovementConstants
extends RefCounted

# ===== PLAYER MOVEMENT =====
const PLAYER_ACCEL_TIME: float = 0.25          # Time to reach max speed
const PLAYER_DECEL_TIME: float = 0.30          # Time to decelerate from blink
const PLAYER_ARRIVAL_THRESHOLD: float = 8.0    # Consider "arrived" when this close
const PLAYER_MOVEMENT_SMOOTHING: float = 12.0  # Target position lerp factor
const PLAYER_SLOWDOWN_DISTANCE: float = 40.0   # Start slowing this close to target
const PLAYER_ROTATION_SPEED: float = 8.0       # Player rotation speed
const PLAYER_MIN_VELOCITY_FOR_ROTATION: float = 30.0

# ===== ENEMY MOVEMENT - BASE CHASE =====
const ENEMY_SPEED_VARIANCE: float = 0.25       # ±25% speed difference per enemy
const ENEMY_DISTANCE_CHECK_INTERVAL: float = 0.1    # Distance calculation frequency
const ENEMY_PROXIMITY_SPEED_BOOST: float = 1.04     # 4% faster when close
const ENEMY_PROXIMITY_DISTANCE: float = 60.0        # Distance for speed boost

# ===== ENEMY MOVEMENT - RANGE KEEPING =====
const RANGE_MODE_CHECK_INTERVAL: float = 0.1
const RANGE_RADIUS_SMOOTHING: float = 1.5
const RANGE_TARGET_SMOOTHING: float = 5.0

# Triangle (baseline values)
const TRIANGLE_INNER_RANGE: float = 250.0
const TRIANGLE_OUTER_RANGE: float = 300.0
const TRIANGLE_CHASE_RANGE: float = 400.0
const TRIANGLE_MASTER_INTERVAL: float = 3.0
const TRIANGLE_RETREAT_REACTION_MIN: float = 2.0
const TRIANGLE_RETREAT_REACTION_MAX: float = 5.0
const TRIANGLE_POSITION_UPDATE_MIN: float = 1.0
const TRIANGLE_POSITION_UPDATE_MAX: float = 5.0

# ===== ENEMY MOVEMENT - SAWBLADE/ORBITAL =====
const SAWBLADE_BASE_OVERSHOOT_DISTANCE: float = 35.0
const SAWBLADE_BASE_TURN_TRIGGER_DISTANCE: float = 30.0
const SAWBLADE_BASE_MIN_ANGLE: float = 1.5708  # PI * 0.5 (90 degrees)
const SAWBLADE_BASE_MAX_ANGLE: float = 4.7124  # PI * 1.5 (270 degrees)
const SAWBLADE_DIRECTION_CHECK_INTERVAL: float = 0.5
const SAWBLADE_MODE_SWITCH_CHECK_INTERVAL: float = 0.05

# Sawblade spinning
const SAWBLADE_BASE_SPIN_SPEED: float = 3.0
const SAWBLADE_SPEED_SPIN_MULTIPLIER: float = 0.003
const SAWBLADE_PROXIMITY_SPIN_BOOST: float = 2.0
const SAWBLADE_PROXIMITY_TRIGGER_DISTANCE: float = 60.0

# Mini sawblade (swarm) enhanced values
const MINI_SAWBLADE_BASE_SPIN_SPEED: float = 5.0
const MINI_SAWBLADE_PROXIMITY_SPIN_BOOST: float = 3.5
const MINI_SAWBLADE_PROXIMITY_TRIGGER_DISTANCE: float = 80.0

# ===== ENEMY MOVEMENT - CHARGE =====
const CHARGE_RANGE: float = 250.0
const CHARGE_DISTANCE_MULTIPLIER: float = 4.0
const CHARGE_ACCELERATION: float = 800.0
const CHARGE_MAX_SPEED: float = 400.0
const CHARGE_COOLDOWN: float = 0.8
const CHARGE_RANGE_CHECK_INTERVAL: float = 0.1
const CHARGE_TARGET_THRESHOLD: float = 20.0   # Close enough to charge target

# ===== ENEMY MOVEMENT - MISSILE HOMING =====
const MISSILE_TURN_SPEED: float = 8.0
const MISSILE_ACCELERATION: float = 300.0
const MISSILE_MAX_SPEED_MULTIPLIER: float = 2.5
const MISSILE_UPDATE_INTERVAL: float = 0.05

# ===== ENEMY MOVEMENT - STAR SPINNING =====
const STAR_BASE_SPIN_SPEED: float = 1.5

# ===== SHIP MOVEMENT =====
const SHIP_MAX_RANGE_FROM_PLAYER: float = 400.0
const SHIP_COMFORT_RANGE: float = 150.0
const SHIP_STRAFE_RANGE_INNER: float = 250.0
const SHIP_STRAFE_RANGE_OUTER: float = 350.0
const SHIP_RETURN_SPEED: float = 300.0
const SHIP_PATROL_SPEED: float = 150.0
const SHIP_STRAFE_SPEED: float = 180.0
const SHIP_ACCELERATION: float = 400.0
const SHIP_ROTATION_SPEED: float = 4.0
const SHIP_POSITION_SMOOTHING: float = 3.0
const SHIP_SPEED_VARIANCE: float = 0.15

# ===== TARGETING SYSTEM =====
const TARGET_SEARCH_RANGE: float = 350.0
const TARGET_SWITCH_INTERVAL: float = 2.0
const TARGET_SWITCH_VARIANCE: float = 1.0
const TARGET_SEARCH_INTERVAL: float = 0.2

# ===== ROTATION CONSTANTS =====
const UNIVERSAL_ROTATION_SPEED: float = 3.0    # Default enemy rotation

# ===== DISTANCE THRESHOLDS =====
const MIN_VELOCITY_FOR_ROTATION: float = 10.0  # General minimum velocity threshold

# ===== HELPER METHODS =====
static func get_triangle_ranges() -> Dictionary:
	"""Get Triangle baseline ranges for other enemies to reference"""
	return {
		"inner": TRIANGLE_INNER_RANGE,
		"outer": TRIANGLE_OUTER_RANGE,
		"chase": TRIANGLE_CHASE_RANGE
	}

static func get_triangle_timings() -> Dictionary:
	"""Get Triangle baseline timings for other enemies to reference"""
	return {
		"master_interval": TRIANGLE_MASTER_INTERVAL,
		"retreat_min": TRIANGLE_RETREAT_REACTION_MIN,
		"retreat_max": TRIANGLE_RETREAT_REACTION_MAX,
		"position_min": TRIANGLE_POSITION_UPDATE_MIN,
		"position_max": TRIANGLE_POSITION_UPDATE_MAX
	}

static func calculate_enemy_speed_variance() -> float:
	"""Generate individual speed multiplier for enemy"""
	return randf_range(1.0 - ENEMY_SPEED_VARIANCE, 1.0 + ENEMY_SPEED_VARIANCE)

static func get_random_strafe_direction() -> float:
	"""Get random strafe direction (1.0 or -1.0)"""
	return 1.0 if randf() > 0.5 else -1.0

static func calculate_missile_max_speed(base_speed: float) -> float:
	"""Calculate missile maximum speed"""
	return base_speed * MISSILE_MAX_SPEED_MULTIPLIER
