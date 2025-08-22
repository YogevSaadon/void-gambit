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

# ===== INFECTION/BIO STATUS =====
const INFECTION_TICK_INTERVAL = 0.5  # Seconds between DoT ticks
const MAX_INFECTION_STACKS = 3       # Maximum infection stacks
# Note: INFECTION_STACK_MULTIPLIER is in CombatConstants.gd

# TODO: Other status effects when added
# TODO: Burn/freeze/poison if implemented
# TODO: Spread radius and chance

# ===== TESTING CHECKLIST =====
# [ ] Infection damage correct
# [ ] Spreading works
# [ ] Stacking applies properly
# [ ] Duration correct
