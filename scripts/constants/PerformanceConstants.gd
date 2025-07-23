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
# TODO: Distance check intervals
# TODO: Target update frequencies
# TODO: Maximum query results
# TODO: Validation timings

# ===== TESTING CHECKLIST =====
# [ ] No performance regression
# [ ] Queries return enough results
# [ ] Updates frequent enough
