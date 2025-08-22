# scripts/constants/VisualConstants.gd
class_name VisualConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Flash/tween timings for attacks and damage
# - Color values for explosions and effects
# - Particle system parameters
# - Visual feedback timing

# ===== IMPLEMENTATION STEPS =====
# 1. Extract flash durations from attack scripts
# 2. Extract color values from explosion scripts
# 3. Extract particle parameters from ExplosionEffect
# 4. Extract UI animation timings

# ===== CONSTANTS TO DEFINE =====
# TODO: Flash timings (0.05, 0.10, 0.03, 0.06, 0.1, 0.2, 0.15, 0.3)
# TODO: Explosion colors (white, red/orange)
# TODO: Particle parameters from ExplosionEffect.gd
# TODO: UI animation speeds

# ===== TESTING CHECKLIST =====
# [ ] Attack flashes look the same
# [ ] Explosion colors unchanged
# [ ] Particle effects identical
# [ ] UI animations feel right