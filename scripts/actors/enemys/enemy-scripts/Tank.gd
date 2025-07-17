# scripts/actors/enemys/tank/Tank.gd
extends BaseEnemy
class_name Tank

func _enter_tree() -> void:
	enemy_type = "tank"  
	
	# ── Base stats at power-level 1 ─────
	max_health = 80             # Much tankier than Biter (20)
	max_shield = 0
	speed = 70                  # Much slower than Biter (120)
	shield_recharge_rate = 0

	# Contact-damage numbers (strong contact damage)
	damage = 20                 # Higher than Biter (12)
	damage_interval = 0.6       # Faster than Biter (0.8)

	# ── Metadata ─────
	power_level = 5
	rarity = "common"
	min_level = 4               # Appears from level 2+
	max_level = 8

	# Call parent's _enter_tree
	super._enter_tree()
