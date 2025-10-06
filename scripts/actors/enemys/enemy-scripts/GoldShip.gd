# scripts/actors/enemys/enemy-scripts/GoldShip.gd
extends BaseEnemy
class_name GoldShip

func _enter_tree() -> void:
	enemy_type = "gold_ship"

	max_health = EnemyConstants.GOLDSHIP_BASE_HEALTH
	max_shield = 0
	speed = EnemyConstants.GOLDSHIP_BASE_SPEED
	shield_recharge_rate = 0

	damage = EnemyConstants.GOLDSHIP_BASE_DAMAGE
	damage_interval = EnemyConstants.GOLDSHIP_DAMAGE_INTERVAL
	
	power_level = 1
	
	super._enter_tree()

func _ready() -> void:
	super._ready()
	
	if _drop_handler:
		_drop_handler.queue_free()
		_drop_handler = null

# FIXED: Add missing method for GoldenShipSpawner
func get_budget_power_level() -> int:
	return 1  # Base power level for spawning cost calculations

func on_death() -> void:
	_drop_gold_coin()
	
	if _damage_display:
		_damage_display.detach_active()
	
	if _status and _status.has_method("clear_all"):
		_status.clear_all()
	
	emit_signal("died")

func _drop_gold_coin() -> void:
	var coin_scene = preload("res://scenes/drops/CoinDrop.tscn")
	if coin_scene:
		var coin = coin_scene.instantiate()
		coin.global_position = global_position
		coin.value = power_level
		get_tree().current_scene.add_child(coin)
