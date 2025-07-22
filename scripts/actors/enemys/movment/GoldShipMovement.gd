# scripts/actors/enemys/movement/GoldShipMovement.gd
extends BaseRangeKeepingMovement
class_name GoldShipMovement

func configure_movement() -> void:
	# ===== GOLD SHIP CONFIGURATION =====
	# Gold Ship: Roams at extreme distance, less responsive than Triangle
	
	# ===== RANGES (Extreme distance - farthest ship) =====
	config_inner_range = 1000.0      # Much farther than Mother Ship (910)
	config_outer_range = 1200.0      # Extreme distance - off screen
	config_chase_range = 1200.0      # Rarely gets close at all
	
	# ===== TIMING (Less responsive than Triangle) =====
	config_master_interval = 5.0     # Changes patterns every 5 seconds (vs Triangle's 3)
	config_retreat_reaction_min = 3.0 # Slower than Triangle (2.0)
	config_retreat_reaction_max = 7.0 # Slower than Triangle (5.0)
	config_position_update_min = 2.0  # Less responsive tracking than Triangle (1.0)
	config_position_update_max = 8.0  # Much slower tracking than Triangle (5.0)
	
	# ===== BEHAVIOR (Roaming but not too aggressive) =====
	config_strafe_intensity = 0.8    # Bit less than Triangle (1.0)
	config_back_away_speed = 0.9     # Bit slower than Triangle (1.0)
	
	# ===== ACTION PROBABILITIES (Less pattern changes) =====
	config_strafe_change_chance = 0.25 # Less than Triangle (0.33)
	config_radius_change_chance = 0.4  # Less than Triangle (0.5)
	config_stop_and_go_chance = 0.1    # Less than Triangle (0.15)
	
	# ===== SPEED CHANGE TIMING (Slightly slower than Triangle) =====
	config_slowdown_duration = 0.6    # Bit longer than Triangle (0.5)
	config_speedup_duration = 1.0     # Bit slower than Triangle (0.8)
