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

# ===== DAMAGE NUMBERS =====
const DAMAGE_HOLD_TIME = 0.08
const DAMAGE_FADE_TIME = 0.40
const DAMAGE_FLOAT_SPEED = 30.0
const DAMAGE_COUNT_SPEED = 60.0

# ===== FLASH TIMINGS =====
# Attack flash durations (in/out)
const CONE_ATTACK_FLASH_IN = 0.05
const CONE_ATTACK_FLASH_OUT = 0.10
const STAR_ATTACK_FLASH_IN = 0.05
const STAR_ATTACK_FLASH_OUT = 0.10
const TRIPLE_SHOT_FLASH_IN = 0.03
const TRIPLE_SHOT_FLASH_OUT = 0.06
const MISSILE_LAUNCHER_FLASH_IN = 0.1
const MISSILE_LAUNCHER_FLASH_OUT = 0.2
const CHILD_SHIP_SPAWNER_FLASH_IN = 0.15
const CHILD_SHIP_SPAWNER_FLASH_OUT = 0.3

# Player invulnerability flash
const PLAYER_INVULN_FLASH_IN = 0.05
const PLAYER_INVULN_FLASH_OUT = 0.05

# ===== EXPLOSION COLORS =====
const EXPLOSION_COLOR_WHITE = Color(1, 1, 1, 0.8)
const EXPLOSION_COLOR_ENEMY = Color(1, 0.3, 0.1, 0.8)  # Red/orange

# ===== UI ANIMATIONS =====
const BAR_UPDATE_SPEED = 5.0
const DAMAGE_NUMBER_DURATION = 1.0
const DAMAGE_NUMBER_RISE_SPEED = 50.0
const ANIMATION_DURATION = 0.3
const PANEL_ALPHA = 0.8

# ===== FONT SIZES =====
const FONT_SIZES = {
	"small": 12,
	"medium": 16,
	"large": 24,
	"title": 32
}

# ===== RARITY COLORS =====
const RARITY_COLORS = {
	"common": Color.WHITE,
	"uncommon": Color.GREEN,
	"rare": Color.BLUE,
	"epic": Color.PURPLE,
	"legendary": Color.ORANGE
}

# ===== TESTING CHECKLIST =====
# [x] Damage numbers float correctly
# [x] Rarity colors match
# [x] UI animations smooth
# [x] Text readable
