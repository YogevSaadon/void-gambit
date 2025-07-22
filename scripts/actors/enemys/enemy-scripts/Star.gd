# scripts/actors/enemys/enemy-scripts/Star.gd
extends BaseEnemy
class_name Star

func _enter_tree() -> void:
	enemy_type = "star"
	
	# ── Base stats at power-level 1 ─────
	max_health = 200            # Much tankier than Triangle (40)
	max_shield = 0
	speed = 35                  # Much slower than Triangle (100)
	shield_recharge_rate = 0
	
	# ── Contact damage (fortress ship) ─────
	damage = 25                 # Much higher than Triangle (15)
	damage_interval = 1.5       # Much slower than Triangle (1.0)
	
	# ── Metadata ─────
	power_level = 5
	rarity = "uncommon"         # Slightly rarer than basic ships
	min_level = 3               # Appears from level 3+
	max_level = 15              # Can appear in very high levels

	# ── FIXED: Disable velocity rotation for spinning ─────
	disable_velocity_rotation = true
	
	# Call parent's _enter_tree to apply power scaling
	super._enter_tree()
