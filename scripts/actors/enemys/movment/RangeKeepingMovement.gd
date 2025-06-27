# RANGE-KEEPING MOVEMENT WITH INTEGRATED SHOOTING
# ================================================
# Reverted to simpler, more dynamic approach
# No inspector configuration needed - all values hardcoded for consistency

extends BaseChaseMovement
class_name RangeKeepingMovement

# ===== HARDCODED RANGE VALUES (no exports) =====
const INNER_RANGE: float = 250.0        # Too close - back away
const OUTER_RANGE: float = 300.0        # Optimal shooting range  
const CHASE_RANGE: float = 400.0        # Return to chase beyond this
const STRAFE_INTENSITY: float = 1.2     # Side-to-side movement strength
const BACK_AWAY_SPEED: float = 1.3      # Speed when retreating

# ===== HARDCODED SHOOTING VALUES =====
const SHOOT_INTERVAL: float = 5.0       # 5 seconds between shots
const BURST_COUNT: int = 1              # Single shot only
const BURST_DELAY: float = 0.0          # No burst delay needed
const MIN_FACING_ANGLE: float = 0.2     # Tighter aiming requirement
const AIMING_DURATION: float = 0.8      # How long to aim before shooting

# ===== MOVEMENT STATE =====
var strafe_direction: float = 1.0       # 1.0 = right, -1.0 = left
var strafe_switch_timer: float = 0.0
var current_mode: String = "CHASE"      # CHASE, MANEUVER, RETREAT, AIMING

# ===== SHOOTING STATE =====
var shoot_timer: float = 0.0
var aiming_timer: float = 0.0           # Timer for aiming phase
var has_shot: bool = false              # Track if we've taken our shot
var cached_player: Node2D = null
var enemy_bullet_scene: PackedScene = preload("res://scenes/bullets/enemy_projectiles/EnemyBullet.tscn")

# ===== PERFORMANCE TIMERS =====
var mode_check_timer: float = 0.0
var player_check_timer: float = 0.0
var strafe_switch_timer_max: float = 0.0

# ===== CONSTANTS =====
const MODE_CHECK_INTERVAL: float = 0.1
const PLAYER_CHECK_INTERVAL: float = 0.1
const STRAFE_SWITCH_MIN: float = 1.0
const STRAFE_SWITCH_MAX: float = 3.0

func _on_movement_ready() -> void:
	# Initialize random values
	strafe_direction = 1.0 if randf() > 0.5 else -1.0
	
	# Stagger all timers
	mode_check_timer = randf() * MODE_CHECK_INTERVAL
	player_check_timer = randf() * PLAYER_CHECK_INTERVAL
	shoot_timer = randf() * SHOOT_INTERVAL
	_reset_strafe_timer()

func tick_movement(delta: float) -> void:
	# Call parent movement logic first
	super.tick_movement(delta)
	
	# Then handle our shooting
	_tick_shooting(delta)

func _calculate_target_position(player: Node2D, delta: float) -> Vector2:
	# Update mode periodically
	mode_check_timer -= delta
	if mode_check_timer <= 0.0:
		mode_check_timer = MODE_CHECK_INTERVAL
		_update_current_mode()
	
	# Handle strafe switching (only when not aiming)
	if current_mode != "AIMING":
		strafe_switch_timer -= delta
		if strafe_switch_timer <= 0.0:
			strafe_direction *= -1.0
			_reset_strafe_timer()
	
	# Calculate movement based on mode
	match current_mode:
		"CHASE":
			return _chase_movement(player)
		"MANEUVER":
			return _maneuver_movement(player)
		"RETREAT":
			return _retreat_movement(player)
		"AIMING":
			return _aiming_movement(player)
		_:
			return player.global_position

func _update_current_mode() -> void:
	var distance = get_cached_distance_to_player()
	
	# PRIORITY: If shoot timer is ready and we're in range, start aiming
	if shoot_timer <= 0.0 and distance <= CHASE_RANGE and distance >= INNER_RANGE and not has_shot:
		current_mode = "AIMING"
		aiming_timer = AIMING_DURATION
		return
	
	# If we're currently aiming, stay in aiming mode until done
	if current_mode == "AIMING":
		return
	
	# Normal movement based on distance
	if distance > CHASE_RANGE:
		current_mode = "CHASE"
	elif distance < INNER_RANGE:
		current_mode = "RETREAT"
	else:
		current_mode = "MANEUVER"

func _chase_movement(player: Node2D) -> Vector2:
	# Direct aggressive chase
	return player.global_position

func _maneuver_movement(player: Node2D) -> Vector2:
	# AGGRESSIVE SPIRAL: Move toward player while strafing (original dynamic approach)
	var to_player = player.global_position - enemy.global_position
	var distance = to_player.length()
	
	# Calculate perpendicular vector for strafing
	var perp = Vector2(-to_player.y, to_player.x).normalized()
	var strafe_offset = perp * strafe_direction * STRAFE_INTENSITY * 50.0
	
	# Target a point that slowly closes distance while strafing
	var maintain_distance_point = player.global_position - to_player.normalized() * OUTER_RANGE
	return maintain_distance_point + strafe_offset

func _retreat_movement(player: Node2D) -> Vector2:
	# Back away with side movement
	var to_player = player.global_position - enemy.global_position
	var away_from_player = -to_player.normalized()
	
	# Add strafe for unpredictable retreat
	var perp = Vector2(-to_player.y, to_player.x).normalized()
	var strafe_offset = perp * strafe_direction * STRAFE_INTENSITY * 30.0
	
	var retreat_point = enemy.global_position + away_from_player * 100.0
	return retreat_point + strafe_offset

func _aiming_movement(player: Node2D) -> Vector2:
	# AIMING MODE: Stop strafing, face the player directly
	# Move slightly to maintain good shooting position
	var to_player = player.global_position - enemy.global_position
	var distance = to_player.length()
	
	# Small position adjustments to maintain optimal range
	if distance < OUTER_RANGE * 0.9:
		# Too close - back away slightly
		var away_direction = -to_player.normalized()
		return enemy.global_position + away_direction * 10.0
	elif distance > OUTER_RANGE * 1.1:
		# Too far - move closer slightly
		var toward_player = to_player.normalized()
		return enemy.global_position + toward_player * 10.0
	else:
		# Good position - hold steady for aiming
		return enemy.global_position

func _get_speed_multiplier() -> float:
	# Different speeds for different behaviors
	match current_mode:
		"CHASE":
			return 1.0
		"MANEUVER":
			return 0.9
		"RETREAT":
			return BACK_AWAY_SPEED
		"AIMING":
			return 0.2  # Very slow when aiming
		_:
			return 1.0

func _reset_strafe_timer() -> void:
	strafe_switch_timer = randf_range(STRAFE_SWITCH_MIN, STRAFE_SWITCH_MAX)

# ===== INTEGRATED SHOOTING SYSTEM (DELIBERATE SINGLE SHOTS) =====

func _tick_shooting(delta: float) -> void:
	# Cache player reference periodically
	player_check_timer -= delta
	if player_check_timer <= 0.0:
		player_check_timer = PLAYER_CHECK_INTERVAL
		cached_player = EnemyUtils.get_player() as Node2D
	
	if cached_player == null:
		return
	
	# Handle aiming sequence
	if current_mode == "AIMING":
		aiming_timer -= delta
		
		# Check if we're aimed well enough to shoot
		if aiming_timer <= 0.0 and _can_shoot():
			_fire_single_bullet()
			has_shot = true
			shoot_timer = SHOOT_INTERVAL  # Reset shoot timer
			current_mode = "MANEUVER"     # Return to normal movement
			print("SmartShip fired aimed shot!")
		elif aiming_timer <= 0.0:
			# Aiming time expired but couldn't get a good shot
			current_mode = "MANEUVER"
			print("SmartShip aiming timeout - returning to maneuver")
	else:
		# Handle shoot timing
		shoot_timer -= delta
		if shoot_timer <= 0.0:
			has_shot = false  # Ready for next shot cycle

func _can_shoot() -> bool:
	if cached_player == null:
		return false
	
	# PRECISE AIMING: Only shoot when well-aimed
	var to_player = (cached_player.global_position - enemy.global_position).normalized()
	var enemy_facing = Vector2(cos(enemy.rotation), sin(enemy.rotation))
	var angle_diff = abs(to_player.angle_to(enemy_facing))
	
	# Tighter aiming requirement when in aiming mode
	return angle_diff < MIN_FACING_ANGLE

func _fire_single_bullet() -> void:
	if enemy_bullet_scene == null or cached_player == null:
		return
	
	# Get muzzle position from Muzzle node
	var muzzle_node = enemy.get_node_or_null("Muzzle")
	var muzzle_pos: Vector2
	if muzzle_node:
		muzzle_pos = muzzle_node.global_position
	else:
		# Fallback: front of enemy
		var front_offset = Vector2(12, 0).rotated(enemy.rotation)
		muzzle_pos = enemy.global_position + front_offset
	
	# Precise shot - no spread for aimed shots
	var direction = (cached_player.global_position - muzzle_pos).normalized()
	
	# Create and configure bullet
	var bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = muzzle_pos
	bullet.direction = direction
	bullet.rotation = direction.angle()
	
	# Use enemy's scaled damage (matches contact damage)
	bullet.damage = enemy.damage
	
	# Add to scene
	enemy.get_tree().current_scene.add_child(bullet)
