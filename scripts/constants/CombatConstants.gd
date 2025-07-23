# scripts/constants/CombatConstants.gd
class_name CombatConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - All damage calculations
# - Critical hit system
# - Armor damage reduction
# - Status effect damage (infection, burn)
# - Damage number display
# - Player invulnerability frames

# ===== IMPLEMENTATION STEPS =====
# 1. Search for damage multipliers (0.33, 1.5, 0.05)
# 2. Search for crit-related values
# 3. Search for armor formula (100.0)
# 4. Search for status tick rates

# ===== CONSTANTS TO DEFINE =====
# TODO: Extract from weapon scripts (0.33 for ships, 1.5 for explosions)
# TODO: Extract from DamageNumber.gd (hold/fade times)
# TODO: Extract from Player.gd (invuln time)
# TODO: Extract from StatusComponent.gd (tick intervals)

# ===== TESTING CHECKLIST =====
# [ ] Damage values match original
# [ ] Crits work correctly
# [ ] Armor reduces damage properly
# [ ] Status effects tick at right rate
# [ ] Damage numbers display correctly
