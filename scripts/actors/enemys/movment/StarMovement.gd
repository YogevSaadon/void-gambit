# scripts/actors/enemys/movement/StarMovement.gd
extends BaseRangeKeepingMovement
class_name StarMovement

# ===== NEW: SPINNING CONFIGURATION =====
@export var base_spin_speed: float = 1.5     # Constant rotation speed (radians per second)

# ===== NEW: SPINNING STATE =====
var cumulative_rotation: float = 0.0 # Total rotation for smooth spinning

func configure_movement() -> void:
	# ===== STAR CONFIGURATION =====
	# Star: Extreme long-range fortress that stays consistently far
	
	# ===== RANGES (Consistent extreme distance) =====
	config_inner_range = 600.0       # Much further back than Triangle (250)
	config_outer_range = 620.0       # Very tight range band (only 20px difference)
	config_chase_range = 800.0       # Only approaches if extremely far (vs 400)
	
	# ===== TIMING (Extremely slow reactions) =====
	config_master_interval = 12.0    # Very slow reactions (vs Triangle's 3.0)
	config_retreat_reaction_min = 8.0 # Very slow retreat reactions (vs 2.0)
	config_retreat_reaction_max = 15.0 # Takes extremely long to react (vs 5.0)
	config_position_update_min = 5.0  # Updates player position very rarely
	config_position_update_max = 15.0 # Extremely slow tracking - almost blind
	
	# ===== BEHAVIOR (Maximum defensive) =====
	config_strafe_intensity = 0.2    # Minimal strafing (vs 1.0)
	config_back_away_speed = 0.4     # Very slow retreat (vs 1.0)
	
	# ===== ACTION PROBABILITIES (Very methodical) =====
	config_strafe_change_chance = 0.05 # Rarely changes direction (vs 0.33)
	config_radius_change_chance = 0.1  # Few radius changes (vs 0.5)
	config_stop_and_go_chance = 0.01   # Almost never does stop-and-go (vs 0.15)
	
	# ===== SPEED CHANGE TIMING (Very sluggish) =====
	config_slowdown_duration = 1.5    # Much longer slowdown (vs 0.5)
	config_speedup_duration = 2.5     # Very slow recovery (vs 0.8)

# ===== NEW: OVERRIDE MOVEMENT TO ADD SPINNING =====
func _on_movement_ready() -> void:
	# Call parent initialization
	super._on_movement_ready()
	
	# Random initial rotation to prevent sync
	cumulative_rotation = randf() * TAU

func _calculate_target_position(player: Node2D, delta: float) -> Vector2:
	# ===== NEW: UPDATE SPINNING ROTATION =====
	_update_spinning_rotation(delta)
	
	# Call parent movement calculation
	return super._calculate_target_position(player, delta)

# ===== NEW: SPINNING ROTATION SYSTEM =====
func _update_spinning_rotation(delta: float) -> void:
	"""Update the constant spinning rotation of the star"""
	# Simple constant spin - no speed variations
	cumulative_rotation += base_spin_speed * delta
	enemy.rotation = cumulative_rotation
	
	# Keep rotation in reasonable range to prevent float overflow
	if cumulative_rotation > TAU * 10:
		cumulative_rotation -= TAU * 10
