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

# ===== CONTACT DAMAGE VALUES =====
const CONTACT_DAMAGE = {
	"mini_biter": 10,
	"biter": 15,
	"child_ship": 20,
	"triangle": 25,
	"rectangle": 30,
	"star": 35,
	"diamond": 50,
	"tank": 75,
	"mother_ship": 100,
	"gold_ship": 25
}

# ===== ENEMY HEALTH VALUES =====
const ENEMY_HEALTH = {
	"mini_biter": 50,
	"biter": 100,
	"child_ship": 150,
	"triangle": 200,
	"rectangle": 250,
	"star": 300,
	"diamond": 500,
	"tank": 1000,
	"mother_ship": 1500,
	"gold_ship": 200
}

# ===== SHIELD SYSTEM =====
const SHIELD_VALUES = {
	"player_max": 100,
	"player_recharge_rate": 5.0,
	"player_recharge_delay": 3.0
}

# ===== DAMAGE MULTIPLIERS =====
const DAMAGE_MULTIPLIERS = {
	"critical": 2.0,
	"weakness": 1.5,
	"resistance": 0.5
}

const CRITICAL_HIT_CHANCE = 0.1

# ===== PLAYER COMBAT =====
const PLAYER_INVULNERABILITY_TIME = 1.0

# ===== STATUS EFFECTS =====
const STATUS_TICK_INTERVALS = {
	"infection": 1.0,
	"burn": 0.5,
	"poison": 1.5
}

# ===== TESTING CHECKLIST =====
# [x] Damage values match original
# [x] Crits work correctly
# [x] Armor reduces damage properly
# [x] Status effects tick at right rate
# [x] Damage numbers display correctly
