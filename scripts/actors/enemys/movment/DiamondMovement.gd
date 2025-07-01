# scripts/actors/enemys/movement/DiamondMovement.gd
extends BaseRangeKeepingMovement
class_name DiamondMovement

func configure_movement() -> void:
	# ===== DIAMOND CONFIGURATION =====
	# Diamond: Large defensive ship, keeps good distance, very slow reactions
	
	# ===== RANGES (Farther than Triangle, closer than Star) =====
	config_inner_range = 400.0       # Farther than Triangle (250) but closer than Star (600)
	config_outer_range = 450.0       # Good distance from Triangle (300)
	config_chase_range = 500.0       # Moderate chase range
	
	# ===== TIMING (Very slow reactions) =====
	config_master_interval = 6.0     # Slower than Triangle (3.0) but faster than Star (12.0)
	config_retreat_reaction_min = 4.0 # Slow retreat reactions
	config_retreat_reaction_max = 9.0 # Takes long to react
	config_position_update_min = 2.0  # Updates player position slowly
	config_position_update_max = 8.0  # Slow tracking
	
	# ===== BEHAVIOR (Defensive but not extreme) =====
	config_strafe_intensity = 0.7    # Less strafing than Triangle (1.0)
	config_back_away_speed = 0.8     # Slower retreat than Triangle (1.0)
	
	# ===== ACTION PROBABILITIES (Methodical) =====
	config_strafe_change_chance = 0.25 # Changes direction less than Triangle (0.33)
	config_radius_change_chance = 0.4  # Fewer radius changes than Triangle (0.5)
	config_stop_and_go_chance = 0.1    # Less stop-and-go than Triangle (0.15)
	
	# ===== SPEED CHANGE TIMING (Sluggish) =====
	config_slowdown_duration = 0.7    # Longer slowdown than Triangle (0.5)
	config_speedup_duration = 1.1     # Slower recovery than Triangle (0.8)
