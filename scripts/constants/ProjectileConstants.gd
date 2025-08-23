# scripts/constants/ProjectileConstants.gd
class_name ProjectileConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - All projectile speeds (bullets, missiles, enemy shots)
# - Projectile lifetimes and ranges
# - Explosion radii and damage
# - Collision detection timing

# ===== IMPLEMENTATION STEPS =====
# 1. Extract speeds from BaseBullet, PlayerBullet, EnemyBullet, PlayerMissile
# 2. Extract lifetimes from projectile scripts
# 3. Extract explosion properties from BaseExplosion, PlayerMissile, RocketWeapon

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
const EXPLOSION_DURATION = 0.15

# ===== TESTING CHECKLIST =====
# [x] Projectiles move at correct speeds
# [x] Bullets despawn at right time
# [x] Explosions have proper radius
# [x] No performance impact
