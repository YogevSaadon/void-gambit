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

# ===== PROJECTILE SPEEDS =====
const BASE_BULLET_SPEED = 1000.0
const PLAYER_BULLET_SPEED = 1800.0
const ENEMY_BULLET_SPEED = 400.0
const PLAYER_MISSILE_SPEED = 450.0

# ===== PROJECTILE LIFETIMES =====
const BASE_BULLET_LIFETIME = 2.0
const PLAYER_BULLET_LIFETIME = 2.0
const ENEMY_BULLET_LIFETIME = 3.0

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

# TODO: Extract remaining weapon-specific values

# ===== DATA FILE =====
# See: scripts/constants/data/weapon_stats.json

# ===== TESTING CHECKLIST =====
# [ ] Bullet damage correct
# [ ] Laser tick damage correct
# [ ] Explosion radius correct
# [ ] Fire rates unchanged
# [ ] Ship weapons do 33% damage
