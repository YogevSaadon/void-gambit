# scripts/constants/StatusConstants.gd
class_name StatusConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Infection/bio damage behavior
# - Status effect durations
# - Tick intervals and damage
# - Spread mechanics
# - Stack limits

# ===== IMPLEMENTATION STEPS =====
# 1. Extract from StatusComponent.gd
# 2. Find bio weapon values
# 3. Extract spread chances

# ===== CONSTANTS TO DEFINE =====
# TODO: Tick intervals (0.5)
# TODO: Max stacks (3)
# TODO: Damage multipliers per stack (0.33)
# TODO: Spread radius and chance

# ===== TESTING CHECKLIST =====
# [ ] Infection damage correct
# [ ] Spreading works
# [ ] Stacking applies properly
# [ ] Duration correct
