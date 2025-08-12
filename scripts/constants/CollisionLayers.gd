# scripts/constants/CollisionLayers.gd
class_name CollisionLayers
extends RefCounted

# ===== COLLISION LAYERS (Bit positions, not inspector numbers) =====
const LAYER_PLAYER = 1              # Bit 1 = Inspector Layer 2
const LAYER_ENEMIES = 2             # Bit 2 = Inspector Layer 3  
const LAYER_PLAYER_PROJECTILES = 4  # Bit 4 = Inspector Layer 5
const LAYER_ENEMY_PROJECTILES = 5   # Bit 5 = Inspector Layer 6

# ===== COLLISION MASKS =====
const MASK_PLAYER = 0                          # Player detects nothing via collision
const MASK_ENEMIES = 0                         # Enemies detect nothing via collision  
const MASK_PLAYER_PROJECTILES = 1 << 2         # Player projectiles detect enemies (bit 2)
const MASK_ENEMY_PROJECTILES = 1 << 1          # Enemy projectiles detect player (bit 1)
const MASK_CONTACT_DAMAGE = 1 << 1             # Contact damage zones detect player (bit 1)

# ===== UTILITY FUNCTIONS =====
static func get_layer_bit(layer_number: int) -> int:
	"""Convert layer number to bit flag"""
	return 1 << layer_number

static func get_player_layer() -> int:
	return 1 << LAYER_PLAYER

static func get_enemy_layer() -> int:
	return 1 << LAYER_ENEMIES

static func get_player_projectile_layer() -> int:
	return 1 << LAYER_PLAYER_PROJECTILES

static func get_enemy_projectile_layer() -> int:
	return 1 << LAYER_ENEMY_PROJECTILES
