extends BaseEnemy
class_name Biter

func _enter_tree() -> void:
	# ── Base stats at power-level 1 ───────────────────────────────
	max_health           = 20
	max_shield           = 0
	speed                = 150
	shield_recharge_rate = 0

	# Contact-damage numbers that ContactDamage.gd will read
	damage          = 12          # per tick
	damage_interval = 0.8         # seconds

	# ── Metadata ─────────────────────────────────────────────────
	power_level = 1
	rarity      = "common"
	min_level   = 1
	max_level   = 5

	# Child nodes (ChaseMovement, ContactDamage, etc.) deliver behaviour.
	super._enter_tree()
