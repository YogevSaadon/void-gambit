# scripts/actors/enemys/tank/Tank.gd
extends BaseEnemy
class_name Tank

func _enter_tree() -> void:
	enemy_type = "tank"

	# ── Base stats at power-level 1 ─────
	max_health = EnemyConstants.TANK_BASE_HEALTH
	max_shield = 0
	speed = EnemyConstants.TANK_BASE_SPEED
	shield_recharge_rate = 0

	# Contact-damage numbers (strong contact damage)
	damage = EnemyConstants.TANK_BASE_DAMAGE
	damage_interval = EnemyConstants.TANK_DAMAGE_INTERVAL

	# ── Metadata ─────
	power_level = 5
	rarity = "common"
	min_level = 4               # Appears from level 2+
	max_level = 8

	# Call parent's _enter_tree
	super._enter_tree()
