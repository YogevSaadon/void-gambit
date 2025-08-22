# scripts/constants/DropConstants.gd
class_name DropConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Credit/coin drop values
# - Pickup magnetism behavior
# - Drop movement physics
# - Collection thresholds

# ===== IMPLEMENTATION STEPS =====
# 1. Extract from DropPickup.gd
# 2. Find drop value multipliers
# 3. Extract movement parameters

# ===== DROP PICKUP BEHAVIOR =====
const PICKUP_RADIUS = 120.0
const PICKUP_THRESHOLD = 15.0
const PICKUP_SPEED_SLOW = 200.0
const PICKUP_SPEED_FAST = 2000.0
const ACCELERATION_POWER = 3.0
const DISTANCE_POWER = 2.5
const PLAYER_SPEED_MULTIPLIER = 1.5
const DROP_LERP_SPEED = 8.0

# ===== DROP VALUES =====
const CREDIT_DROP_MULTIPLIER = 4.0  # Credit value multiplier

# TODO: Golden coin values
# TODO: Rare drop chances

# ===== TESTING CHECKLIST =====
# [ ] Drops magnetize at right distance
# [ ] Collection feels smooth
# [ ] Values match original
