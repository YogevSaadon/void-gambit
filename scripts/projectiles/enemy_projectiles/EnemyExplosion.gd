# scripts/projectiles/enemy_projectiles/EnemyExplosion.gd
extends BaseExplosion
class_name EnemyExplosion

# ====== Enemy-specific configuration ======
func _ready() -> void:
	# Configure for enemy explosions (red/orange, targets player)
	target_group = "Player"                    # Target the player
	explosion_collision_layer = 5              # Enemy explosions on layer 5
	explosion_collision_mask = 1               # Detect player on layer 1
	initial_color = Color(1, 0.3, 0.1, 0.8)   # Red/orange color instead of white
	
	# Call parent _ready to set up collision and visuals
	super._ready()
