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

# ===== CONSTANTS TO DEFINE =====
# TODO: Base weapon stats
# TODO: Projectile properties
# TODO: Special ability values
# TODO: Ship weapon reductions (0.33)

# ===== DATA FILE =====
# See: scripts/constants/data/weapon_stats.json

# ===== TESTING CHECKLIST =====
# [ ] Bullet damage correct
# [ ] Laser tick damage correct
# [ ] Explosion radius correct
# [ ] Fire rates unchanged
# [ ] Ship weapons do 33% damage
