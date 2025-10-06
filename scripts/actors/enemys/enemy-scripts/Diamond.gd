# scripts/actors/enemys/diamond/Diamond.gd
extends BaseEnemy
class_name Diamond

func _enter_tree() -> void:
	enemy_type = "diamond"

	# ── Base stats at power-level 1 ─────
	max_health = EnemyConstants.DIAMOND_BASE_HEALTH
	max_shield = 0
	speed = EnemyConstants.DIAMOND_BASE_SPEED
	shield_recharge_rate = 0

	# ── Contact damage (big ship) ─────
	damage = EnemyConstants.DIAMOND_BASE_DAMAGE
	damage_interval = EnemyConstants.DIAMOND_DAMAGE_INTERVAL

	
	# Call parent's _enter_tree to apply power scaling
	super._enter_tree()
