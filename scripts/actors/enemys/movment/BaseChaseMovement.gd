# BASE CHASE MOVEMENT SYSTEM
# ==========================
# Shared functionality for all enemy chase behaviors
# Handles: speed variation, player targeting, performance optimization
# Override: _calculate_target_position() for specific movement patterns

extends Node2D
class_name BaseChaseMovement

# ===== SHARED CONTROLS =====
@export var speed_scale: float = 1.0         # Overall speed multiplier

var enemy: BaseEnemy
var individual_speed_multiplier: float = 1.0  # Each enemy gets unique speed (prevents robotic movement)

# ===== PERFORMANCE OPTIMIZATIONS =====
# These prevent FPS spikes by spreading expensive calculations across multiple frames
var distance_check_timer: float = 0.0        # Timer for expensive distance calculations
var cached_distance_to_player: float = 0.0   # Cached result to avoid repeated sqrt operations

# ===== PERFORMANCE INTERVALS =====
const DISTANCE_CHECK_INTERVAL: float = 0.1    # Check distance every 0.1 seconds (not every frame)

func _enter_tree() -> void:
	enemy = get_parent() as BaseEnemy
	assert(enemy != null, "BaseChaseMovement expects a BaseEnemy parent")
	
	# INDIVIDUAL SPEED VARIATION: Each enemy gets ±25% speed difference
	# This creates natural swarm spreading without expensive spacing calculations
	var speed_variance = 0.25
	individual_speed_multiplier = randf_range(1.0 - speed_variance, 1.0 + speed_variance)
	
	# STAGGER PERFORMANCE TIMERS: Prevents all enemies from calculating simultaneously
	distance_check_timer = randf() * DISTANCE_CHECK_INTERVAL
	
	# Allow subclasses to initialize
	_on_movement_ready()

# OVERRIDE THIS: Subclasses implement their specific targeting logic
func _calculate_target_position(player: Node2D, delta: float) -> Vector2:
	# Default: direct chase (basic behavior)
	return player.global_position

# OVERRIDE THIS: Subclasses can add initialization logic
func _on_movement_ready() -> void:
	pass

func tick_movement(delta: float) -> void:
	var player: Node2D = EnemyUtils.get_player() as Node2D
	if player == null:
		enemy.velocity = Vector2.ZERO
		return

	# OPTIMIZATION: Cache expensive distance calculation (sqrt is expensive)
	distance_check_timer -= delta
	if distance_check_timer <= 0.0:
		distance_check_timer = DISTANCE_CHECK_INTERVAL
		cached_distance_to_player = enemy.global_position.distance_to(player.global_position)
	
	# SPEED CALCULATION: Base speed with individual variation
	var base_speed = enemy.speed * speed_scale * individual_speed_multiplier
	
	# PROXIMITY SPEED BOOST: Slight speed increase when close (creates dramatic moments)
	var speed_multiplier = _get_speed_multiplier()
	var final_speed = base_speed * speed_multiplier
	
	# GET TARGET FROM SUBCLASS: Each movement type calculates differently
	var target_position = _calculate_target_position(player, delta)
	
	# APPLY MOVEMENT: Move toward calculated target
	var direction = (target_position - enemy.global_position).normalized()
	enemy.velocity = direction * final_speed

# SPEED MODIFICATION: Can be overridden by subclasses
func _get_speed_multiplier() -> float:
	# Default: Slight speed increase when close
	if cached_distance_to_player < 60.0:
		return 1.04  # Only 4% faster to avoid "charging" feeling
	return 1.0

# HELPER: Get cached distance (avoids expensive recalculation)
func get_cached_distance_to_player() -> float:
	return cached_distance_to_player
