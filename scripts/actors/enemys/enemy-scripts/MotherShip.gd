# scripts/actors/enemys/mothership/MotherShip.gd
extends BaseEnemy
class_name MotherShip

func _enter_tree() -> void:
	enemy_type = "mother_ship"

	# ── Base stats at power-level 1 ─────
	max_health = EnemyConstants.MOTHERSHIP_BASE_HEALTH
	max_shield = 0
	speed = EnemyConstants.MOTHERSHIP_BASE_SPEED
	shield_recharge_rate = 0

	# ── Contact damage (huge ship) ─────
	damage = EnemyConstants.MOTHERSHIP_BASE_DAMAGE
	damage_interval = EnemyConstants.MOTHERSHIP_DAMAGE_INTERVAL

	
	# Call parent's _enter_tree to apply power scaling
	super._enter_tree()

func on_death() -> void:
	# Mother Ship drops double credits as mentioned in notepad
	if _drop_handler:
		# Temporarily double the drop value
		var original_multiplier = _drop_handler.drop_value_multiplier
		_drop_handler.drop_value_multiplier = original_multiplier * 2.0
	
	# Normal death with doubled drops
	super.on_death()
