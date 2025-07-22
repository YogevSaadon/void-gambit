# scripts/actors/enemys/movement/EnemyMissileMovement.gd
extends BaseChaseMovement
class_name EnemyMissileMovement

# ===== MISSILE MOVEMENT CONFIGURATION =====
@export var turn_speed: float = 8.0           # FIXED: Much higher for sharp turns (was 2.0)
@export var acceleration: float = 300.0       # How fast it speeds up
@export var max_speed_multiplier: float = 2.5 # Max speed = base_speed * this
@export var update_interval: float = 0.05     # FIXED: More frequent updates (was 0.15)

# ===== MISSILE STATE =====
var current_speed: float = 0.0
var target_direction: Vector2 = Vector2.RIGHT
var last_update_time: float = 0.0

func _on_movement_ready() -> void:
	# Start slower, will accelerate to max speed
	current_speed = enemy.speed * 0.4  # Start at 40% speed
	
	# Randomize initial direction slightly
	target_direction = Vector2.RIGHT.rotated(randf_range(-PI/4, PI/4))

func _calculate_target_position(player: Node2D, delta: float) -> Vector2:
	# FIXED: Update targeting direction more frequently
	last_update_time += delta
	if last_update_time >= update_interval:
		last_update_time = 0.0
		target_direction = (player.global_position - enemy.global_position).normalized()
	
	# Accelerate toward max speed
	var max_speed = enemy.speed * max_speed_multiplier
	current_speed = min(current_speed + acceleration * delta, max_speed)
	
	# Get current movement direction
	var current_direction = enemy.velocity.normalized() if enemy.velocity.length() > 0 else Vector2.RIGHT
	
	# FIXED: Much sharper turning with higher turn_speed
	var new_direction = current_direction.lerp(target_direction, turn_speed * delta).normalized()
	
	# Set velocity directly (missiles don't use target position)
	enemy.velocity = new_direction * current_speed
	
	# Return target for completeness (though we control movement via velocity)
	return enemy.global_position + (new_direction * 100.0)

func _get_speed_multiplier() -> float:
	# We handle speed manually, so return 1.0
	return 1.0

# ===== DEBUG INFO =====
func get_missile_info() -> Dictionary:
	return {
		"current_speed": current_speed,
		"target_direction": target_direction,
		"max_speed": enemy.speed * max_speed_multiplier,
		"turn_sharpness": turn_speed
	}
