# scripts/actors/enemys/enemy-scripts/Biter.gd
extends BaseEnemy
class_name Biter

func _enter_tree() -> void:
	enemy_type = "biter"

	# ── Base stats at power-level 1 ─────
	max_health = EnemyConstants.BITER_BASE_HEALTH
	max_shield = 0
	speed = EnemyConstants.BITER_BASE_SPEED
	shield_recharge_rate = 0

	# Contact-damage numbers
	damage = EnemyConstants.BITER_BASE_DAMAGE
	damage_interval = EnemyConstants.BITER_DAMAGE_INTERVAL

	# ── FIXED: Disable velocity rotation for spinning ─────
	disable_velocity_rotation = true

	# Call parent's _enter_tree
	super._enter_tree()
