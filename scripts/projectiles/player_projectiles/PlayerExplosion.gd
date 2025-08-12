# scripts/projectiles/player_projectiles/PlayerExplosion.gd
extends BaseExplosion
class_name PlayerExplosion

# ====== Player-specific configuration ======
func _ready() -> void:
	# Configure for player explosions
	target_group = "Enemies"
	explosion_collision_layer = CollisionLayers.LAYER_PLAYER_PROJECTILES  
	explosion_collision_mask = CollisionLayers.LAYER_ENEMIES   
	
	# Call parent _ready to set up collision and visuals
	super._ready()
