# scripts/constants/SpawningConstants.gd
class_name SpawningConstants
extends RefCounted

#right now sould be ignored before spawning system is not finished and im still experimenting

# ===== WHAT THIS AFFECTS =====
# - Power budget calculations
# - Spawn intervals and batch sizes
# - Wave duration and progression
# - Enemy tier multipliers
# - Golden ship spawning

# ===== IMPLEMENTATION STEPS =====
# 1. Extract from PowerBudgetCalculator.gd
# 2. Find spawn timing in WaveManager.gd
# 3. Extract tier breakpoints and multipliers
# 4. Link to wave_progression.json

# ===== WAVE MANAGEMENT =====
const SPAWN_BATCH_INTERVAL = 1.0
const ENEMY_SPAWN_INTERVAL = 0.05
const LEVEL_DURATION = 60.0
const MAX_ENEMIES_ALIVE = 250
const FIXED_DURATION = 35.0
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

# ===== DATA FILE =====
# See: scripts/constants/data/wave_progression.json

# ===== TESTING CHECKLIST =====
# [ ] Wave difficulty scales correctly
# [ ] Spawn timing feels right
# [ ] Golden ships appear on schedule
# [ ] Power budgets balanced
