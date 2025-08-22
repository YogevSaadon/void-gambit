# scripts/constants/PerformanceConstants.gd
class_name PerformanceConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Update intervals for expensive operations
# - Spatial query limits
# - Cache durations
# - Maximum entity counts

# ===== IMPLEMENTATION STEPS =====
# 1. Find all timer intervals (0.1, 0.2)
# 2. Find spatial query limits (32)
# 3. Extract cache timings

# ===== CONSTANTS TO DEFINE =====
# Query limits for physics intersect_shape calls
const MAX_PHYSICS_QUERY_RESULTS = 32  # Used in BaseEnemy, ShooterWeapon, ChainLaserBeamController, TargetSelector
const MAX_BIO_SPREAD_TARGETS = 5       # Used in UniversalShipWeapon for bio spread

# Timer intervals for expensive operations
const RANGE_CHECK_INTERVAL = 0.2
const DISTANCE_CHECK_INTERVAL = 0.1
const MODE_CHECK_INTERVAL = 0.1
const SEARCH_INTERVAL = 0.2

# TODO: Target update frequencies
# TODO: Cache durations

# ===== TESTING CHECKLIST =====
# [ ] No performance regression
# [ ] Queries return enough results
# [ ] Updates frequent enough
