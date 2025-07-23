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

# ===== CONSTANTS TO DEFINE =====
# TODO: Pickup ranges (120.0, 15.0)
# TODO: Movement speeds (200.0, 2000.0)
# TODO: Acceleration curves (3.0, 2.5)
# TODO: Drop value multipliers

# ===== TESTING CHECKLIST =====
# [ ] Drops magnetize at right distance
# [ ] Collection feels smooth
# [ ] Values match original
