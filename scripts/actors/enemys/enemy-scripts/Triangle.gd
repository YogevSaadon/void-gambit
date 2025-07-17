# scripts/actors/enemys/smart_ship/SmartShip.gd
extends BaseEnemy
class_name Triangle

func _enter_tree() -> void:
	enemy_type = "smart_ship"
	
	# ── Base stats at power-level 1 ─────
	max_health = 40          # Tougher than Biter (20)
	max_shield = 0
	speed = 70              # Slightly slower than Biter (120) - more tactical
	shield_recharge_rate = 0
	
	# ── Contact damage (all ships are dangerous to touch) ─────
	damage = 15              # Between Biter (12) and its toughness  
	damage_interval = 1.0    # Standard contact damage timing
	
	# ── Metadata ─────
	power_level = 2
	rarity = "common"
	min_level = 1
	max_level = 10           # Can appear in higher levels
	
	# Call parent's _enter_tree to apply power scaling
	super._enter_tree()
