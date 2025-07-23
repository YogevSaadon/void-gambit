# scripts/constants/EnemyConstants.gd
class_name EnemyConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - All enemy base stats (health, speed, damage)
# - Enemy-specific behaviors
# - Contact damage values
# - Power level scaling
# - Enemy spawn requirements

# ===== IMPLEMENTATION STEPS =====
# 1. Extract base stats from each enemy script
# 2. Create methods to get stats by enemy type
# 3. Link to enemy_stats.json for designer tweaking

# ===== CONSTANTS TO DEFINE =====
# TODO: Move all base stats from enemy scripts
# TODO: Define which stats should be in JSON vs code
# TODO: Create stat getter methods

# ===== DATA FILE =====
# See: scripts/constants/data/enemy_stats.json

# ===== TESTING CHECKLIST =====
# [ ] Each enemy has correct health
# [ ] Movement speeds match original
# [ ] Contact damage works
# [ ] Power scaling applies correctly
