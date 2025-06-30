# scripts/actors/enemys/movement/TriangleMovement.gd
extends BaseRangeKeepingMovement
class_name TriangleMovement

func configure_movement() -> void:
	# ===== TRIANGLE CONFIGURATION =====
	# Triangle uses the ORIGINAL values - this is the baseline behavior
	
	# ===== RANGES (Original values) =====
	config_inner_range = 250.0       # Original
	config_outer_range = 300.0       # Original
	config_chase_range = 400.0       # Original
	
	# ===== TIMING (Original values) =====
	config_master_interval = 3.0     # Original
	config_retreat_reaction_min = 2.0 # Original
	config_retreat_reaction_max = 5.0 # Original
	config_position_update_min = 1.0  # Original
	config_position_update_max = 5.0  # Original
	
	# ===== BEHAVIOR (Original values) =====
	config_strafe_intensity = 1.0    # Original
	config_back_away_speed = 1.0     # Original
	
	# ===== ACTION PROBABILITIES (Original values) =====
	config_strafe_change_chance = 0.33 # Original
	config_radius_change_chance = 0.5  # Original
	config_stop_and_go_chance = 0.15   # Original
	
	# ===== SPEED CHANGE TIMING (Original values) =====
	config_slowdown_duration = 0.5    # Original
	config_speedup_duration = 0.8     # Original
