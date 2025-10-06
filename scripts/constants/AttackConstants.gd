# scripts/constants/AttackConstants.gd
class_name AttackConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Enemy attack behavior (ranges, intervals, damage)
# - Attack patterns (cone angles, bullet counts)
# - Spawner configurations (child ships, missiles)
# - Attack timing and cooldowns

# ===== BASE ATTACK DAMAGE =====
const CONE_ATTACK_DAMAGE = 15.0
const STAR_ATTACK_DAMAGE = 25.0
const TRIANGLE_ATTACK_DAMAGE = 15.0
const TRIPLE_SHOT_DAMAGE = 10.0

# ===== ATTACK RANGES =====
const CONE_ATTACK_RANGE = 500.0
const STAR_ATTACK_RANGE = 5000.0
const TRIANGLE_ATTACK_RANGE = 400.0
const TRIPLE_SHOT_RANGE = 350.0
const MISSILE_LAUNCHER_RANGE = 1000.0
const CHILD_SHIP_SPAWNER_RANGE = 5000.0

# ===== FIRE INTERVALS =====
const CONE_FIRE_INTERVAL = 3.0
const STAR_FIRE_INTERVAL = 6.0
const TRIANGLE_FIRE_INTERVAL = 3.0
const TRIPLE_SHOT_BURST_INTERVAL = 3.0
const MISSILE_LAUNCHER_INTERVAL = 5.0
const CHILD_SHIP_SPAWN_INTERVAL = 6.0

# ===== SPECIAL ATTACK PROPERTIES =====
# Cone Attack
const CONE_ANGLE = 45.0  # degrees

# Star Attack
const STAR_BULLET_COUNT = 16

# Triple Shot Attack
const TRIPLE_SHOT_SHOTS_PER_BURST = 3
const TRIPLE_SHOT_SHOT_DELAY = 0.15
const TRIPLE_SHOT_SPREAD_ANGLE = 15.0

# Child Ship Spawner
const CHILD_SHIP_SPAWN_OFFSET_DISTANCE = 50.0

# ===== RANGE CHECK INTERVAL =====
const RANGE_CHECK_INTERVAL = 0.2

# ===== TESTING CHECKLIST =====
# [ ] Cone attack fires at correct range and interval
# [ ] Star attack creates 16-bullet pattern
# [ ] Triangle attack has correct range
# [ ] Triple shot bursts work correctly
# [ ] Missile launcher timing correct
# [ ] Child ships spawn from MotherShip
