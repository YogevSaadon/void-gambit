# /scripts/enemies/biter/Biter.gd
extends BaseEnemy
class_name Biter

const MOVE := preload("res://scripts/actors/enemys/movment/ChaseMovement.gd")

func _enter_tree() -> void:
	# 1) Designer base stats (power-level 1)
	max_health = 20
	max_shield = 0
	speed      = 150
	shield_recharge_rate = 0

	# 2) Metadata
	power_level = 1
	rarity      = "common"
	min_level   = 1
	max_level   = 5

	# 3) Behaviour
	movement_script = MOVE
	attack_script   = null        # no ranged plug-in
	damage          = 12
	damage_interval = 0.8

	# 4) Nothing else: body layer/mask & zone mask come from BaseEnemy
	super._enter_tree()
