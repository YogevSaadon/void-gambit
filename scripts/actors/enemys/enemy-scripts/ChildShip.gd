# scripts/actors/enemys/child/ChildShip.gd
extends BaseEnemy
class_name ChildShip

func _enter_tree() -> void:
	enemy_type = "child_ship"

	# ── Base stats at power-level 1 ─────
	max_health = EnemyConstants.CHILDSHIP_BASE_HEALTH
	max_shield = 0
	speed = EnemyConstants.CHILDSHIP_BASE_SPEED
	shield_recharge_rate = 0

	# Contact-damage numbers (same as Triangle)
	damage = EnemyConstants.CHILDSHIP_BASE_DAMAGE
	damage_interval = EnemyConstants.CHILDSHIP_DAMAGE_INTERVAL       

	# Call parent's _enter_tree
	super._enter_tree()

func _ready() -> void:
	super._ready()
	
	# DISABLE DROPS: Child ships don't drop loot (only Mother Ship does)
	if _drop_handler:
		_drop_handler.queue_free()
		_drop_handler = null  # Prevents "previously freed" errors
