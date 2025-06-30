# scripts/actors/enemys/movement/RectangleMovement.gd
extends BaseRangeKeepingMovement
class_name RectangleMovement

func configure_movement() -> void:
	# ===== RECTANGLE CONFIGURATION =====
	# Rectangle: 4 second reactions + less response time, everything else same as Triangle
	
	# ===== RANGES (Same as Triangle baseline) =====
	config_inner_range = 250.0       # Same as Triangle
	config_outer_range = 300.0       # Same as Triangle
	config_chase_range = 400.0       # Same as Triangle
	
	# ===== TIMING =====
	config_master_interval = 4.0     # SLOWER reactions (4 vs 3 seconds)
	config_retreat_reaction_min = 3.0 # Less responsive (vs 2.0)
	config_retreat_reaction_max = 6.0 # Less responsive (vs 5.0)
	config_position_update_min = 1.5  # Updates player position less often
	config_position_update_max = 6.0  # Less responsive tracking
	
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
