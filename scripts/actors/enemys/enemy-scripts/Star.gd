# scripts/actors/enemys/enemy-scripts/Star.gd
extends BaseEnemy
class_name Star

func _enter_tree() -> void:
	enemy_type = "star"

	# ── Base stats at power-level 1 ─────
	max_health = EnemyConstants.STAR_BASE_HEALTH
	max_shield = 0
	speed = EnemyConstants.STAR_BASE_SPEED
	shield_recharge_rate = 0

	# ── Contact damage (fortress ship) ─────
	damage = EnemyConstants.STAR_BASE_DAMAGE
	damage_interval = EnemyConstants.STAR_DAMAGE_INTERVAL
	

	# ── FIXED: Disable velocity rotation for spinning ─────
	disable_velocity_rotation = true
	
	# Call parent's _enter_tree to apply power scaling
	super._enter_tree()
