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

# ===== CONSTANTS TO DEFINE =====
# TODO: Bullet speeds (1000, 400, 1800, 450)
# TODO: Lifetimes (2.0, 3.0)
# TODO: Explosion radii (64.0, 80.0)
# TODO: Explosion durations (0.15)

# ===== TESTING CHECKLIST =====
# [ ] Projectiles move at correct speeds
# [ ] Bullets despawn at right time
# [ ] Explosions have proper radius
# [ ] No performance impact