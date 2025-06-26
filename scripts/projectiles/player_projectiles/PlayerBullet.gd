# scripts/projectiles/player_projectiles/PlayerBullet.gd
extends BaseBullet
class_name PlayerBullet

# ====== Player-specific configuration ======
func _ready() -> void:
	# Configure for player bullets
	speed = 1000.0
	max_lifetime = 2.0
	target_group = "Enemies"
	bullet_collision_layer = 4  # Player bullets on layer 4
	bullet_collision_mask = 2   # Detect enemies on layer 2
	
	# Call parent _ready to set up collision and signals
	super._ready()
