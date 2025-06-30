# scripts/actors/enemys/movement/MissileMovement.gd
extends BaseChaseMovement
class_name MissileMovement

# ===== MISSILE HOMING CONFIGURATION =====
@export var homing_strength: float = 3.0       # How aggressively it homes
@export var acceleration: float = 200.0        # How fast it speeds up
@export var max_speed_multiplier: float = 2.0  # Max speed = enemy.speed * this

# ===== HOMING STATE =====
var current_speed: float = 0.0
var target_velocity: Vector2 = Vector2.ZERO

func _on_movement_ready() -> void:
	# Start at slower speed, will accelerate
	current_speed = enemy.speed * 0.3  # Start at 30% speed

func _calculate_target_position(player: Node2D, delta: float) -> Vector2:
	# Simple homing missile - always move toward player
	var to_player = (player.global_position - enemy.global_position).normalized()
	
	# Accelerate toward max speed
	var max_speed = enemy.speed * max_speed_multiplier
	current_speed = min(current_speed + acceleration * delta, max_speed)
	
	# Set velocity for homing behavior
	target_velocity = to_player * current_speed
	enemy.velocity = target_velocity
	
	# Return player position (though velocity is what matters for missiles)
	return player.global_position

func _get_speed_multiplier() -> float:
	# We handle speed manually in _calculate_target_position
	return current_speed / enemy.speed if enemy.speed > 0 else 1.0

# ===== OPTIONAL: More sophisticated homing ===== 
func _calculate_homing_velocity(player: Node2D, delta: float) -> Vector2:
	"""Alternative: More realistic missile homing with turn rate limits"""
	var to_player = (player.global_position - enemy.global_position).normalized()
	var current_dir = enemy.velocity.normalized() if enemy.velocity.length() > 0 else Vector2.RIGHT
	
	# Blend current direction with target direction based on homing strength
	var new_direction = current_dir.lerp(to_player, homing_strength * delta).normalized()
	
	return new_direction * current_speed
