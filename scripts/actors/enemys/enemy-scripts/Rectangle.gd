# scripts/actors/enemys/smart_ship/SmartShip.gd
extends BaseEnemy
class_name Rectangle

func _enter_tree() -> void:
	enemy_type = "smart_ship"

	# ── Base stats at power-level 1 ─────
	max_health = EnemyConstants.RECTANGLE_BASE_HEALTH
	max_shield = 0
	speed = EnemyConstants.RECTANGLE_BASE_SPEED
	shield_recharge_rate = 0

	# ── Contact damage (all ships are dangerous to touch) ─────
	damage = EnemyConstants.RECTANGLE_BASE_DAMAGE
	damage_interval = EnemyConstants.RECTANGLE_DAMAGE_INTERVAL

	
	# Call parent's _enter_tree to apply power scaling
	super._enter_tree()
