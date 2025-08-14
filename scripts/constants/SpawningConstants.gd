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

# ===== CONSTANTS TO DEFINE =====
# TODO: Power budget formula values
# TODO: Spawn intervals (10.0, 0.3)
# TODO: Tier breakpoints (6, 12, 18, 24)
# TODO: Duration scaling (30.0 to 60.0)

# ===== DATA FILE =====
# See: scripts/constants/data/wave_progression.json

# ===== TESTING CHECKLIST =====
# [ ] Wave difficulty scales correctly
# [ ] Spawn timing feels right
# [ ] Golden ships appear on schedule
# [ ] Power budgets balanced
