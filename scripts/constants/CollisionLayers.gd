# scripts/constants/CollisionLayers.gd
class_name CollisionLayers
extends RefCounted

# ===== COLLISION LAYER BIT POSITIONS =====
# These store bit positions (0-based) for use with bit shifting (1 << position)
# Godot Inspector shows layers as 1-based numbers
const LAYER_PLAYER = 1              # Bit position 1 → Inspector Layer 2
const LAYER_ENEMIES = 2             # Bit position 2 → Inspector Layer 3
const LAYER_PLAYER_PROJECTILES = 4  # Bit position 4 → Inspector Layer 5
const LAYER_ENEMY_PROJECTILES = 5   # Bit position 5 → Inspector Layer 6

# ===== USAGE EXAMPLES =====
# collision_layer = 1 << CollisionLayers.LAYER_PLAYER        → Layer bit 1 (value 2)
# collision_mask = 1 << CollisionLayers.LAYER_ENEMIES        → Mask bit 2 (value 4)
# 
# This approach stores bit POSITIONS as constants, letting each object
# do its own bit shifting in set_collision_properties() methods.
