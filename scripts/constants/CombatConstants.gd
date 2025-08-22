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

# ===== DAMAGE MULTIPLIERS =====
# Critical multipliers used throughout combat system
const SHIP_DAMAGE_REDUCTION = 0.33        # Ship weapons do 33% of player damage
const EXPLOSION_DAMAGE_MULTIPLIER = 1.5   # Explosions do 1.5x base damage
const LASER_DAMAGE_MULTIPLIER = 0.05      # Laser ticks do 5% of base damage
const BIO_DPS_DIVISOR = 3.0               # Bio DPS = base_damage / 3.0
const INFECTION_STACK_MULTIPLIER = 0.33   # Each infection stack adds 33% damage

# ===== CONSTANTS TO DEFINE =====
# TODO: Extract from DamageNumber.gd (hold/fade times)
# TODO: Extract from Player.gd (invuln time)
# TODO: Extract from StatusComponent.gd (tick intervals)

# ===== TESTING CHECKLIST =====
# [ ] Damage values match original
# [ ] Crits work correctly
# [ ] Armor reduces damage properly
# [ ] Status effects tick at right rate
# [ ] Damage numbers display correctly
