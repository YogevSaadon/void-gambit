# scripts/actors/enemys/movement/MotherShipMovement.gd
extends BaseRangeKeepingMovement
class_name MotherShipMovement

func configure_movement() -> void:
	# ===== MOTHER SHIP CONFIGURATION =====
	# Mother Ship: Extreme defensive fortress, stays very far back
	
	# ===== RANGES (30% farther than before) =====
	config_inner_range = 910.0       # 30% farther than 700
	config_outer_range = 975.0       # 30% farther than 750
	config_chase_range = 1040.0      # 30% farther than 800
	
	# ===== TIMING (Very slow reactions - almost like Star) =====
	config_master_interval = 10.0    # Very slow reactions
	config_retreat_reaction_min = 6.0 # Very slow retreat reactions
	config_retreat_reaction_max = 12.0 # Takes very long to react
	config_position_update_min = 4.0  # Updates player position rarely
	config_position_update_max = 12.0 # Very slow tracking
	
	# ===== BEHAVIOR (Maximum defensive) =====
	config_strafe_intensity = 0.4    # Minimal strafing
	config_back_away_speed = 0.6     # Very slow retreat
	
	# ===== ACTION PROBABILITIES (Very methodical) =====
	config_strafe_change_chance = 0.15 # Rarely changes direction
	config_radius_change_chance = 0.3  # Few radius changes
	config_stop_and_go_chance = 0.05   # Almost never does stop-and-go
	
	# ===== SPEED CHANGE TIMING (Very sluggish) =====
	config_slowdown_duration = 1.0    # Longer slowdown
	config_speedup_duration = 1.5     # Very slow recovery
