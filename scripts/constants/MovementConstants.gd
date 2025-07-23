# scripts/constants/MovementConstants.gd
class_name MovementConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Player movement (acceleration, rotation)
# - Enemy movement patterns (chase, strafe, orbit)
# - Ship movement behaviors
# - Projectile speeds and lifetimes
# - Blink system
# - Drop pickup magnetism

# ===== IMPLEMENTATION STEPS =====
# 1. Search in PlayerMovement.gd for timing values
# 2. Search in enemy movement scripts for ranges/speeds
# 3. Search for rotation speeds
# 4. Search for distance thresholds

# ===== CONSTANTS TO DEFINE =====
# TODO: Player movement (0.25, 0.30, 8.0, 12.0)
# TODO: Enemy ranges (250.0, 300.0, 600.0)
# TODO: Sawblade patterns (15.0, 3.0)
# TODO: Charge behaviors (800.0, 400.0)

# ===== TESTING CHECKLIST =====
# [ ] Player movement feels the same
# [ ] Enemy patterns unchanged
# [ ] Ships orbit correctly
# [ ] Charge attacks work
# [ ] Sawblades spin properly
