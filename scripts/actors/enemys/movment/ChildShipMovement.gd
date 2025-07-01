# scripts/actors/enemys/movement/ChildShipMovement.gd
extends BaseRangeKeepingMovement
class_name ChildShipMovement

func configure_movement() -> void:
	# ===== CHILD SHIP CONFIGURATION =====
	# Child Ship: Faster and more aggressive than Triangle
	
	# ===== RANGES (Slightly closer than Triangle) =====
	config_inner_range = 220.0       # Bit closer than Triangle (250)
	config_outer_range = 280.0       # Bit closer than Triangle (300)
	config_chase_range = 420.0       # Slightly more aggressive than Triangle (400)
	
	# ===== TIMING (Faster reactions than Triangle) =====
	config_master_interval = 2.0     # Faster than Triangle (3.0)
	config_retreat_reaction_min = 1.0 # Faster than Triangle (2.0)
	config_retreat_reaction_max = 3.0 # Faster than Triangle (5.0)
	config_position_update_min = 0.5  # Much faster tracking than Triangle (1.0)
	config_position_update_max = 2.5  # Much faster tracking than Triangle (5.0)
	
	# ===== BEHAVIOR (Same as Triangle baseline) =====
	config_strafe_intensity = 1.0    # Same as Triangle
	config_back_away_speed = 1.0     # Same as Triangle
	
	# ===== ACTION PROBABILITIES (Same as Triangle baseline) =====
	config_strafe_change_chance = 0.33 # Same as Triangle
	config_radius_change_chance = 0.5  # Same as Triangle
	config_stop_and_go_chance = 0.15   # Same as Triangle
	
	# ===== SPEED CHANGE TIMING (Same as Triangle baseline) =====
	config_slowdown_duration = 0.5    # Same as Triangle
	config_speedup_duration = 0.8     # Same as Triangle
