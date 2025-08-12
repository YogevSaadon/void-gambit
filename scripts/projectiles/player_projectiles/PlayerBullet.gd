# scripts/projectiles/player_projectiles/PlayerBullet.gd
extends BaseBullet
class_name PlayerBullet

# ====== Player-specific configuration ======
func _ready() -> void:
	# Configure for player bullets
	speed = 1800.0
	max_lifetime = 2.0
	target_group = "Enemies"
	bullet_collision_layer = CollisionLayers.LAYER_PLAYER_PROJECTILES  
	bullet_collision_mask = CollisionLayers.LAYER_ENEMIES  
	
	# Call parent _ready to set up collision and signals
	super._ready()
