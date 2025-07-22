# scripts/actors/enemys/mothership/MotherShip.gd
extends BaseEnemy
class_name MotherShip

func _enter_tree() -> void:
	enemy_type = "mother_ship"
	
	# ── Base stats at power-level 1 ─────
	max_health = 400            # Much tankier than Diamond (250)
	max_shield = 0
	speed = 45                  # Much slower than Diamond (45)
	shield_recharge_rate = 0
	
	# ── Contact damage (huge ship) ─────
	damage = 40                 # Higher than Diamond (30)
	damage_interval = 2.5       # Much slower than Diamond (2.0)

	
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
