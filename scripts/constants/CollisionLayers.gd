# scripts/constants/CollisionLayers.gd
class_name CollisionLayers
extends RefCounted

# ===== COLLISION LAYERS =====
# Bit positions for collision_layer
const LAYER_PLAYER = 1              # Player CharacterBody2D
const LAYER_ENEMIES = 2             # Enemy Area2D nodes
const LAYER_PLAYER_PROJECTILES = 4  # Player bullets, explosions, missiles
const LAYER_ENEMY_PROJECTILES = 5   # Enemy bullets, explosions

# ===== COLLISION MASKS =====
# What each type should detect (1 << layer_number)
const MASK_PLAYER = 0                          # Player detects nothing via collision
const MASK_ENEMIES = 0                         # Enemies detect nothing via collision
const MASK_PLAYER_PROJECTILES = 1 << 2         # Player projectiles detect enemies
const MASK_ENEMY_PROJECTILES = 1 << 1          # Enemy projectiles detect player
const MASK_CONTACT_DAMAGE = 1 << 1             # Contact damage zones detect player

# ===== UTILITY FUNCTIONS =====
static func get_layer_bit(layer_number: int) -> int:
	"""Convert layer number to bit flag"""
	return 1 << layer_number

static func get_player_layer() -> int:
	return get_layer_bit(LAYER_PLAYER)

static func get_enemy_layer() -> int:
	return get_layer_bit(LAYER_ENEMIES)

static func get_player_projectile_layer() -> int:
	return get_layer_bit(LAYER_PLAYER_PROJECTILES)

static func get_enemy_projectile_layer() -> int:
	return get_layer_bit(LAYER_ENEMY_PROJECTILES)
