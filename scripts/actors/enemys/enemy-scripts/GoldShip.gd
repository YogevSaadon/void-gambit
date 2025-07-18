# scripts/actors/enemys/goldship/GoldShip.gd
extends BaseEnemy
class_name GoldShip

func _enter_tree() -> void:
	enemy_type = "gold_ship"
	
	# ── Base stats at power-level 1 ─────
	max_health = 80            # Tanky to survive being hunted
	max_shield = 0
	speed = 120                 # Bit faster than Triangle (100)
	shield_recharge_rate = 0
	
	# ── Contact damage (valuable but dangerous) ─────
	damage = 20                 # Higher than Triangle (15)
	damage_interval = 1.0       # Same as Triangle
	
	# ── Metadata ─────
	power_level = 1             # Will be set based on stage level
	rarity = "special"          # Special spawning - not in normal waves
	min_level = 1               # Can appear in any stage
	max_level = 50              # Scales with stage progression
	
	# Call parent's _enter_tree to apply power scaling
	super._enter_tree()

func _ready() -> void:
	super._ready()
	
	# DISABLE NORMAL DROPS: Gold ship has special drop behavior
	if _drop_handler:
		_drop_handler.queue_free()
		_drop_handler = null  # Use the missile fix pattern

func on_death() -> void:
	# Drop single gold coin instead of normal loot
	_drop_gold_coin()
	
	# Custom death without normal drops
	if _damage_display:
		_damage_display.detach_active()
	
	if _status and _status.has_method("clear_all"):
		_status.clear_all()
	
	emit_signal("died")

func _drop_gold_coin() -> void:
	"""Drop exactly one gold coin"""
	var coin_scene = preload("res://scenes/drops/CoinDrop.tscn")
	if coin_scene:
		var coin = coin_scene.instantiate()
		coin.global_position = global_position
		coin.value = power_level  # Coin value scales with Gold Ship's power level
		get_tree().current_scene.add_child(coin)
		print("Gold Ship dropped gold coin worth %d" % coin.value)
