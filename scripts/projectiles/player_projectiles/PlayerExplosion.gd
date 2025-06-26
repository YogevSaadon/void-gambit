# scripts/projectiles/player_projectiles/PlayerExplosion.gd
extends BaseExplosion
class_name PlayerExplosion

# ====== Player-specific configuration ======
func _ready() -> void:
	# Configure for player explosions
	target_group = "Enemies"
	explosion_collision_layer = 4  # Player explosions on layer 4
	explosion_collision_mask = 2   # Detect enemies on layer 2
	
	# Call parent _ready to set up collision and visuals
	super._ready()
