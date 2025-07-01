# scripts/actors/enemys/child/ChildShip.gd
extends BaseEnemy
class_name ChildShip

func _enter_tree() -> void:
	enemy_type = "child_ship"  
	
	# ── Base stats at power-level 1 ─────
	max_health = 35             # Slightly weaker than Triangle (40)
	max_shield = 0
	speed = 130                 # Faster than Triangle (100)
	shield_recharge_rate = 0

	# Contact-damage numbers (same as Triangle)
	damage = 15                 
	damage_interval = 1.0       

	# ── Metadata ─────
	power_level = 1             # Will inherit from Mother Ship
	rarity = "common"
	min_level = 1               # Can only come from Mother Ship
	max_level = 20              # Scales with Mother Ship level

	# Call parent's _enter_tree
	super._enter_tree()

func _ready() -> void:
	super._ready()
	
	# DISABLE DROPS: Child ships don't drop loot (only Mother Ship does)
	if _drop_handler:
		_drop_handler.queue_free()
		_drop_handler = null  # Prevents "previously freed" errors
