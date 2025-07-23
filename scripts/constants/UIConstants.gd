# scripts/constants/UIConstants.gd
class_name UIConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Damage number display
# - Health/shield bar sizing
# - UI animations and transitions
# - Color schemes for rarities
# - Text formatting

# ===== IMPLEMENTATION STEPS =====
# 1. Extract from DamageNumber.gd (timing, speed)
# 2. Find rarity colors in PassiveItem.gd
# 3. Extract UI animation durations
# 4. Find text size constants

# ===== CONSTANTS TO DEFINE =====
# TODO: Damage number behavior (0.08, 0.40, 30.0)
# TODO: Rarity colors
# TODO: UI transition times
# TODO: Bar sizes and offsets

# ===== TESTING CHECKLIST =====
# [ ] Damage numbers float correctly
# [ ] Rarity colors match
# [ ] UI animations smooth
# [ ] Text readable
