# scripts/projectiles/enemy_projectiles/EnemyBullet.gd
extends BaseBullet
class_name EnemyBullet

# ====== Enemy-specific configuration ======
func _ready() -> void:
	# Configure for enemy bullets (slower, red, targets player)
	speed = 400.0                  # Slower than player bullets
	max_lifetime = 3.0             # Longer lifetime since slower
	target_group = "Player"        # Target the player
	bullet_collision_layer = 5     # Enemy bullets on layer 5
	bullet_collision_mask = 1      # Detect player on layer 1
	
	# Call parent _ready to set up collision and signals
	super._ready()
