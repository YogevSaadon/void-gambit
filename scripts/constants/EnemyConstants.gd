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

# ===== ENEMY BASE STATS =====
# Base stats at power level 1 - these scale with enemy power

# Biter - Fast melee enemy
const BITER_BASE_HEALTH = 20
const BITER_BASE_SPEED = 120
const BITER_BASE_DAMAGE = 12
const BITER_DAMAGE_INTERVAL = 0.8

# MiniBiter - Smaller, faster version  
const MINI_BITER_BASE_HEALTH = 8
const MINI_BITER_BASE_SPEED = 130
const MINI_BITER_BASE_DAMAGE = 6
const MINI_BITER_DAMAGE_INTERVAL = 0.7

# Triangle - Basic ranged enemy
const TRIANGLE_BASE_HEALTH = 40
const TRIANGLE_BASE_SPEED = 100
const TRIANGLE_BASE_DAMAGE = 15
const TRIANGLE_DAMAGE_INTERVAL = 1.0

# Rectangle - Tanky enemy
const RECTANGLE_BASE_HEALTH = 60
const RECTANGLE_BASE_SPEED = 90
const RECTANGLE_BASE_DAMAGE = 15
const RECTANGLE_DAMAGE_INTERVAL = 1.0

# Tank - Heavy charging enemy
const TANK_BASE_HEALTH = 80
const TANK_BASE_SPEED = 85
const TANK_BASE_DAMAGE = 20
const TANK_DAMAGE_INTERVAL = 0.6

# Star - Multi-shot enemy
const STAR_BASE_HEALTH = 200
const STAR_BASE_SPEED = 80
const STAR_BASE_DAMAGE = 25
const STAR_DAMAGE_INTERVAL = 1.5

# Diamond - High-tier enemy
const DIAMOND_BASE_HEALTH = 250
const DIAMOND_BASE_SPEED = 70
const DIAMOND_BASE_DAMAGE = 30
const DIAMOND_DAMAGE_INTERVAL = 2.0

# MotherShip - Boss-like enemy
const MOTHERSHIP_BASE_HEALTH = 400
const MOTHERSHIP_BASE_SPEED = 45
const MOTHERSHIP_BASE_DAMAGE = 40
const MOTHERSHIP_DAMAGE_INTERVAL = 2.5

# ChildShip - Spawned by MotherShip
const CHILDSHIP_BASE_HEALTH = 35
const CHILDSHIP_BASE_SPEED = 130
const CHILDSHIP_BASE_DAMAGE = 15
const CHILDSHIP_DAMAGE_INTERVAL = 1.0

# GoldShip - Special reward enemy
const GOLDSHIP_BASE_HEALTH = 40
const GOLDSHIP_BASE_SPEED = 90
const GOLDSHIP_BASE_DAMAGE = 20
const GOLDSHIP_DAMAGE_INTERVAL = 1.0

# EnemyMissile - Explosive projectile enemy
const ENEMY_MISSILE_BASE_HEALTH = 30
const ENEMY_MISSILE_BASE_SPEED = 200
const ENEMY_MISSILE_EXPLOSION_DAMAGE = 40.0
const ENEMY_MISSILE_EXPLOSION_RADIUS = 80.0

# ===== POWER LEVELS =====
const POWER_LEVELS = {
	"mini_biter": 1,
	"biter": 2,
	"child_ship": 3,
	"triangle": 4,
	"rectangle": 5,
	"star": 6,
	"diamond": 8,
	"tank": 10,
	"mother_ship": 15,
	"gold_ship": 5
}

# ===== DROP CHANCES =====
const DROP_CHANCES = {
	"coin": 0.3,
	"credit": 0.05,
	"health": 0.02,
	"shield": 0.02
}

# ===== ENEMY SCORES =====
const ENEMY_SCORES = {
	"mini_biter": 10,
	"biter": 20,
	"child_ship": 30,
	"triangle": 40,
	"rectangle": 50,
	"star": 75,
	"diamond": 100,
	"tank": 150,
	"mother_ship": 250,
	"gold_ship": 200
}

# ===== SPAWN WEIGHTS BY WAVE =====
const SPAWN_WEIGHTS_BY_WAVE = {
	1: {"biter": 1.0},
	2: {"biter": 0.7, "mini_biter": 0.3},
	3: {"biter": 0.5, "mini_biter": 0.3, "child_ship": 0.2},
	4: {"biter": 0.4, "mini_biter": 0.2, "child_ship": 0.2, "triangle": 0.2},
	5: {"biter": 0.3, "mini_biter": 0.2, "child_ship": 0.2, "triangle": 0.2, "rectangle": 0.1}
}

# ===== DATA FILE =====
# See: scripts/constants/data/enemy_stats.json

# ===== TESTING CHECKLIST =====
# [x] Each enemy has correct health
# [x] Movement speeds match original
# [x] Contact damage works
# [x] Power scaling applies correctly
