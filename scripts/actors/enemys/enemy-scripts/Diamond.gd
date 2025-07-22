# scripts/actors/enemys/diamond/Diamond.gd
extends BaseEnemy
class_name Diamond

func _enter_tree() -> void:
	enemy_type = "diamond"
	
	# ── Base stats at power-level 1 ─────
	max_health = 250            # Very tanky - more than Star (200)
	max_shield = 0
	speed = 70                  # Slower than Star (35)
	shield_recharge_rate = 0
	
	# ── Contact damage (big ship) ─────
	damage = 30                 # Higher than Star (25)
	damage_interval = 2.0       # Much slower than Star (1.5)

	
	# Call parent's _enter_tree to apply power scaling
	super._enter_tree()
