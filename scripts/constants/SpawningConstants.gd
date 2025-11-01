# scripts/constants/SpawningConstants.gd
class_name SpawningConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Power budget calculations
# - Spawn intervals and batch sizes
# - Wave duration and progression
# - Enemy tier multipliers
# - Golden ship spawning
# - Enemy unlock levels

# ===== WAVE MANAGEMENT =====
const SPAWN_BATCH_INTERVAL = 2.0  # Increased from 1.0 - spawns batches half as often
const ENEMY_SPAWN_INTERVAL = 0.05
const LEVEL_DURATION = 30.0  # All levels are 30 seconds
const MAX_ENEMIES_ALIVE = 250
const INITIAL_BATCH_TIMER = 0.1
const GOLDEN_SHIP_INITIAL_TIMER = 1.0
const GOLDEN_SHIP_TIMING_MULTIPLIER = 0.5  # level_duration * 0.5

# ===== POWER BUDGET =====
const BASE_BUDGET = 10
const BUDGET_SCALING_PER_LEVEL = 0.1  # 10% per level
const BUDGET_TOLERANCE = 1.2  # 20% overspend allowed
const MAX_SPAWN_ATTEMPTS = 1000
const OVERSPEND_THRESHOLD = 0.3  # 30% remaining

# Power tier breakpoints and multipliers
const TIER_1_BREAKPOINT = 6   # Tier 1: levels 1-5
const TIER_2_BREAKPOINT = 12  # Tier 2: levels 6-11
const TIER_3_BREAKPOINT = 18  # Tier 3: levels 12-17
const TIER_4_BREAKPOINT = 24  # Tier 4: levels 18-23
# Tier 5: levels 24+

const TIER_1_MULTIPLIER = 1
const TIER_2_MULTIPLIER = 2
const TIER_3_MULTIPLIER = 3
const TIER_4_MULTIPLIER = 4
const TIER_5_MULTIPLIER = 5

# Wave duration range
const MIN_WAVE_DURATION = 30.0
const MAX_WAVE_DURATION = 60.0
const USABLE_TIME_BUFFER = 0.9  # 90% of wave time usable
const MIN_SPAWN_INTERVAL = 0.1

# ===== LEVEL SPAWN SETTINGS =====
const SPAWN_DISTANCE_VARIANCE = 100.0
const SPAWN_MARGIN = 64.0

# ===== ENEMY UNLOCK LEVELS =====
const BITER_MIN_LEVEL = 1
const MINI_BITER_MIN_LEVEL = 1
const TRIANGLE_MIN_LEVEL = 2
const RECTANGLE_MIN_LEVEL = 3
const TANK_MIN_LEVEL = 4
const STAR_MIN_LEVEL = 5
const DIAMOND_MIN_LEVEL = 7
const MOTHERSHIP_MIN_LEVEL = 10

# ===== GAME CONSTANTS =====
const WAVE_DURATION = 60.0
const SPAWN_RATE_BASE = 2.0
const DIFFICULTY_SCALING = 1.2
const MAX_ENEMIES = 50
const PICKUP_RADIUS = 50.0

# ===== SPAWN PATTERNS =====
const SPAWN_PATTERNS = {
	"random": 0,
	"circle": 1,
	"line": 2,
	"swarm": 3
}

# ===== SCREEN BOUNDS =====
const SCREEN_BOUNDS = {
	"left": -100,
	"right": 2020,
	"top": -100,
	"bottom": 1180
}

# ===== DATA FILE =====
# See: scripts/constants/data/wave_progression.json

# ===== TESTING CHECKLIST =====
# [x] Wave difficulty scales correctly
# [x] Spawn timing feels right
# [x] Golden ships appear on schedule
# [x] Power budgets balanced
