# scripts/actors/enemys/movement/MiniSawbladeMovement.gd
extends SawbladeMovement
class_name MiniSawbladeMovement

# Override the parent's configuration for tighter swarm formation
func _on_movement_ready() -> void:
	# ===== MINI SAWBLADE CONFIGURATION =====
	# Tighter, more aggressive formation for swarms
	
	# ===== FORMATION CONTROL =====
	cloud_size = 0.6                    # Smaller cloud (vs 1.0) - tighter formation
	cloud_tightness = 1.8               # Much tighter (vs 1.0) - more aggressive grouping
	orbit_radius = 8.0                  # Smaller orbit (vs 15.0) - closer contact damage
	orbit_switch_chance = 0.04          # More chaotic (vs 0.02) - more direction changes
	
	# Call parent initialization with our new values
	super._on_movement_ready()
	
	# ===== ADDITIONAL MINI-SPECIFIC TWEAKS =====
	# Make mini-biters even more aggressive in their circulation patterns
	individual_speed_multiplier *= 1.2  # 20% faster than normal variance
	
	# Slightly faster approach angle changes for more chaotic swarm movement
	if randf() < 0.3:  # 30% chance for extra aggressive mini-biter
		orbit_switch_chance *= 2.0  # Double the chaos for some mini-biters
