# scripts/constants/WeaponConstants.gd
class_name WeaponConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - All weapon damage values
# - Fire rates and cooldowns
# - Projectile speeds and lifetimes
# - Special weapon properties (laser reflects, explosion radius)
# - Weapon-specific multipliers

# ===== IMPLEMENTATION STEPS =====
# 1. Extract base damage/fire rate from weapon scripts
# 2. Find all projectile speeds (1800, 400, 450)
# 3. Extract special multipliers (0.05 for laser, 1.5 for explosion)
# 4. Link to weapon_stats.json

# ===== BASE WEAPON STATS =====
const BASE_WEAPON_DAMAGE = 20.0
const BASE_WEAPON_FIRE_RATE = 1.0
const BASE_WEAPON_RANGE = 300.0

# ===== WEAPON-SPECIFIC FIRE RATES =====
const ROCKET_FIRE_RATE = 0.7
const SHIP_SPAWN_INTERVAL = 0.3

# ===== PROJECTILE SPEEDS MOVED =====
# Moved to ProjectileConstants.gd for better organization

# ===== PROJECTILE LIFETIMES MOVED =====
# Moved to ProjectileConstants.gd for better organization

# ===== EXPLOSION PROPERTIES =====
const BASE_EXPLOSION_RADIUS = 64.0
const BASE_EXPLOSION_FADE_DURATION = 0.15

# ===== LASER PROPERTIES =====
const LASER_TICK_TIME = 0.05
const LASER_VALIDATION_INTERVAL = 0.1

# ===== BIO WEAPON PROPERTIES =====
const BIO_BASE_DURATION = 3.0
const SHIP_BIO_DPS = 15.0
const SHIP_BIO_DURATION = 3.0

# ===== WEAPON COSTS =====
const WEAPON_COSTS = {
	"bullet_weapon": 100,
	"bio_weapon": 200,
	"rocket_weapon": 300,
	"laser_weapon": 500,
	"mini_ship_spawner": 1000
}

# ===== WEAPON UNLOCK LEVELS =====
const WEAPON_UNLOCK_LEVELS = {
	"bullet_weapon": 1,
	"bio_weapon": 3,
	"rocket_weapon": 5,
	"laser_weapon": 8,
	"mini_ship_spawner": 10
}

# ===== WEAPON RARITIES =====
const WEAPON_RARITIES = {
	"common": ["bullet_weapon"],
	"uncommon": ["bio_weapon"],
	"rare": ["rocket_weapon"],
	"epic": ["laser_weapon"],
	"legendary": ["mini_ship_spawner"]
}

# ===== UPGRADE SYSTEM =====
const UPGRADE_COSTS = [100, 250, 500, 1000, 2000]
const MAX_WEAPON_LEVEL = 5

# ===== FIRE RATES =====
const FIRE_RATES = {
	"bullet_weapon": 0.2,
	"bio_weapon": 0.5,
	"rocket_weapon": 1.0,
	"laser_weapon": 0.1,
	"triple_shot": 0.3,
	"cone_attack": 0.4
}

# ===== DATA FILE =====
# See: scripts/constants/data/weapon_stats.json

# ===== TESTING CHECKLIST =====
# [x] Bullet damage correct
# [x] Laser tick damage correct
# [x] Explosion radius correct
# [x] Fire rates unchanged
# [x] Ship weapons do 33% damage
