# scripts/constants/MovementConstants.gd
class_name MovementConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Player movement (acceleration, rotation)
# - Enemy movement patterns (chase, strafe, orbit)
# - Ship movement behaviors
# - Projectile speeds and lifetimes
# - Blink system
# - Drop pickup magnetism

# ===== IMPLEMENTATION STEPS =====
# 1. Search in PlayerMovement.gd for timing values
# 2. Search in enemy movement scripts for ranges/speeds
# 3. Search for rotation speeds
# 4. Search for distance thresholds

# ===== PLAYER MOVEMENT =====
const PLAYER_ACCEL_TIME = 0.25
const PLAYER_DECEL_TIME = 0.30
const PLAYER_ARRIVAL_THRESHOLD = 8.0
const PLAYER_MOVEMENT_SMOOTHING = 12.0
const PLAYER_SLOWDOWN_DISTANCE = 40.0
const PLAYER_ROTATION_SPEED = 8.0
const PLAYER_MIN_VELOCITY_FOR_ROTATION = 30.0
const PLAYER_SNAP_THRESHOLD = 2.0
const PLAYER_STOP_THRESHOLD = 10.0

# ===== ENEMY RANGE KEEPING =====
const ENEMY_INNER_RANGE = 250.0
const ENEMY_OUTER_RANGE = 300.0
const ENEMY_CHASE_RANGE = 400.0
const ENEMY_MASTER_INTERVAL = 3.0
const ENEMY_RETREAT_REACTION_MIN = 2.0
const ENEMY_RETREAT_REACTION_MAX = 5.0
const ENEMY_POSITION_UPDATE_MIN = 1.0
const ENEMY_POSITION_UPDATE_MAX = 5.0
const ENEMY_ZONE_HYSTERESIS = 0.2

# Movement behavior values
const ENEMY_STRAFE_INTENSITY = 1.0
const ENEMY_BACK_AWAY_SPEED = 1.0
const ENEMY_STRAFE_CHANGE_CHANCE = 0.33
const ENEMY_STOP_CHANCE = 0.5
const ENEMY_ACCEL_CHANCE = 0.15
const ENEMY_STOP_DURATION = 0.8
const ENEMY_ACCEL_DURATION = 1.2

# ===== ENEMY-SPECIFIC RANGES =====
# Triangle: Uses base values
# Rectangle: Same ranges, master_interval = 4.0
# ChildShip: 220/280/420 ranges, master_interval = 2.0  
# Diamond: 400/450/500 ranges, master_interval = 6.0
# Star: 600/620/800 ranges, master_interval = 12.0
# MotherShip: 910/975/1040 ranges, master_interval = 10.0
# GoldShip: 1000/1200/1200 ranges, master_interval = 5.0

# ===== CHARGE MOVEMENT (Tank) =====
const CHARGE_RANGE = 250.0
const CHARGE_DISTANCE_MULTIPLIER = 4.0
const CHARGE_ACCELERATION = 800.0
const MAX_CHARGE_SPEED = 400.0
const CHARGE_COOLDOWN = 0.8
const CHARGE_ARRIVAL_THRESHOLD = 20.0

# ===== SAWBLADE MOVEMENT =====
const SAWBLADE_CLOUD_SIZE = 1.0
const SAWBLADE_CLOUD_TIGHTNESS = 1.0
const SAWBLADE_ORBIT_RADIUS = 15.0
const SAWBLADE_ORBIT_SWITCH_CHANCE = 0.02
const SAWBLADE_BASE_SPIN_SPEED = 3.0
const SAWBLADE_SPEED_SPIN_MULTIPLIER = 0.003

# ===== MISSILE MOVEMENT =====
const MISSILE_TURN_SPEED = 8.0
const MISSILE_ACCELERATION = 300.0
const MISSILE_MAX_SPEED_MULTIPLIER = 2.5
const MISSILE_UPDATE_INTERVAL = 0.05
const MISSILE_START_SPEED_MULTIPLIER = 0.4

# ===== TESTING CHECKLIST =====
# [ ] Player movement feels the same
# [ ] Enemy patterns unchanged
# [ ] Ships orbit correctly
# [ ] Charge attacks work
# [ ] Sawblades spin properly
