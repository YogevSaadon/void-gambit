# scripts/constants/CollisionLayers.gd
class_name CollisionLayers
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Player.gd (collision setup)
# - BaseEnemy.gd (collision setup)
# - All projectile scripts (bullets, explosions, missiles)
# - Contact damage systems
# - Weapon targeting systems

# ===== IMPLEMENTATION STEPS =====
# 1. Search for: collision_layer = 1 << [number]
# 2. Search for: collision_mask = 1 << [number]
# 3. Search for: collision_mask = [number]
# 4. Replace magic numbers with these constants

# ===== CONSTANTS TO DEFINE =====
# TODO: Define layer numbers (currently using magic numbers 1,2,4,5)
# const LAYER_PLAYER = ?
# const LAYER_ENEMIES = ?
# const LAYER_PLAYER_PROJECTILES = ?
# const LAYER_ENEMY_PROJECTILES = ?

# ===== TESTING CHECKLIST =====
# [ ] Player takes damage from enemies
# [ ] Enemies take damage from player
# [ ] Projectiles hit correct targets
# [ ] No friendly fire
# [ ] Contact damage works
# [ ] Explosions affect correct targets
