# scripts/actors/enemys/enemy-scripts/MiniBiter.gd
extends BaseEnemy
class_name MiniBiter

func _enter_tree() -> void:
	enemy_type = "mini_biter"  
	
	# ── Base stats at power-level 1 ─────
	max_health = 8              # Much weaker than Biter (20)
	max_shield = 0
	speed = 130                 # Faster than Biter (120)
	shield_recharge_rate = 0

	# Contact-damage numbers
	damage = 6                  # Weaker than Biter (12)
	damage_interval = 0.7       # Slightly faster than Biter (0.8)

	# ── FIXED: Disable velocity rotation for spinning ─────
	disable_velocity_rotation = true

	# ===== NORMAL ENEMY METADATA =====
	power_level = 1          
	rarity = "common"
	min_level = 1               # Can spawn from level 1
	max_level = 25              # No max level restriction

	# Call parent's _enter_tree
	super._enter_tree()
