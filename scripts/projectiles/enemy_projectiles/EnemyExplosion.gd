# scripts/projectiles/enemy_projectiles/EnemyExplosion.gd
extends BaseExplosion
class_name EnemyExplosion

# ===== Enemy-specific configuration =====
func _ready() -> void:
	# Configure for enemy explosions (red/orange, targets player)
	target_group = "Player"                    # Target the player
	explosion_collision_layer = CollisionLayers.LAYER_ENEMY_PROJECTILES            
	explosion_collision_mask = CollisionLayers.LAYER_PLAYER              
	initial_color = Color(1, 0.3, 0.1, 0.8)   # Red/orange color
	
	# Call parent _ready to set up collision and visuals
	super._ready()
	
	# IMPORTANT: For CharacterBody2D collision, we need body_entered not area_entered
	# The parent class connects both, but let's make sure we're monitoring properly
	monitoring = true
	monitorable = false  # Explosions don't need to be detected by others
	
	# Force immediate damage check since explosion appears on player
	_check_immediate_damage()

func _check_immediate_damage() -> void:
	"""Check for player overlap immediately on spawn"""
	# Get all overlapping bodies
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group(target_group):
			_on_collision(body)
	
	# Also check overlapping areas (shouldn't be needed for player but just in case)
	var areas = get_overlapping_areas()
	for area in areas:
		if area.is_in_group(target_group):
			_on_collision(area)
