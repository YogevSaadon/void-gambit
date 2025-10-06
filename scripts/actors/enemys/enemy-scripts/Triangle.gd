# scripts/actors/enemys/smart_ship/SmartShip.gd
extends BaseEnemy
class_name Triangle

func _enter_tree() -> void:
	enemy_type = "smart_ship"

	# ── Base stats at power-level 1 ─────
	max_health = EnemyConstants.TRIANGLE_BASE_HEALTH
	max_shield = 0
	speed = EnemyConstants.TRIANGLE_BASE_SPEED
	shield_recharge_rate = 0

	# ── Contact damage (all ships are dangerous to touch) ─────
	damage = EnemyConstants.TRIANGLE_BASE_DAMAGE
	damage_interval = EnemyConstants.TRIANGLE_DAMAGE_INTERVAL
	
	
	# Call parent's _enter_tree to apply power scaling
	super._enter_tree()
