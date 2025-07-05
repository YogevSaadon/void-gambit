# scripts/projectiles/enemy_projectiles/EnemyExplosion.gd
extends BaseExplosion
class_name EnemyExplosion

# ====== Enemy-specific configuration ======
func _ready() -> void:
	# Configure for enemy explosions (red/orange, targets player)
	target_group = "Player"                    # Target the player
	explosion_collision_layer = 5              # Enemy explosions on layer 5
	explosion_collision_mask = 2               # Detect player on layer 2 (FIXED: was 1, should be 2)
	initial_color = Color(1, 0.3, 0.1, 0.8)   # Red/orange color instead of white
	
	# DEBUG: Print all EnemyExplosion stats
	print("=== ENEMY EXPLOSION DEBUG ===")
	print("Target Group: ", target_group)
	print("Collision Layer: ", explosion_collision_layer)
	print("Collision Mask: ", explosion_collision_mask)
	print("Initial Color: ", initial_color)
	print("Position: ", global_position)
	print("Damage: ", damage)
	print("Radius: ", radius)
	print("Crit Chance: ", crit_chance)
	
	# FIND PLAYER AND TEST COLLISION
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var distance = global_position.distance_to(player.global_position)
		print("Distance to player: ", distance)
		print("Player position: ", player.global_position)
		print("Player collision layer: ", player.collision_layer)
		
		# DIRECT DAMAGE TEST - if collision fails, damage directly
		if distance <= radius:
			print("Player in explosion radius - applying direct damage!")
			if player.has_method("receive_damage"):
				player.receive_damage(int(damage))
				print("Applied ", damage, " damage directly to player")
			else:
				print("ERROR: Player doesn't have receive_damage method!")
	else:
		print("ERROR: No player found in Player group!")
	
	print("===============================")
	
	# Call parent _ready to set up collision and visuals
	super._ready()
