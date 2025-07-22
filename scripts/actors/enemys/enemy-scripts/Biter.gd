# scripts/actors/enemys/enemy-scripts/Biter.gd
extends BaseEnemy
class_name Biter

func _enter_tree() -> void:
	enemy_type = "biter"  
	
	# ── Base stats at power-level 1 ─────
	max_health = 20
	max_shield = 0
	speed = 120
	shield_recharge_rate = 0

	# Contact-damage numbers
	damage = 12
	damage_interval = 0.8

	# ── FIXED: Disable velocity rotation for spinning ─────
	disable_velocity_rotation = true

	# Call parent's _enter_tree
	super._enter_tree()
