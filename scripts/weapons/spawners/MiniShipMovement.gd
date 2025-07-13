# scripts/weapons/spawners/MiniShipMovement.gd
extends Node2D
class_name MiniShipMovement

enum ShipState {
	RETURN_TO_RANGE,
	FIND_TARGET,
	ENGAGE_TARGET
}

# ===== MOVEMENT CONFIGURATION =====
@export var max_range_from_player: float = 400.0
@export var comfort_range: float = 250.0
@export var attack_range: float = 200.0
@export var target_search_range: float = 350.0

@export var cruise_speed: float = 150.0
@export var return_speed: float = 300.0
@export var combat_speed: float = 180.0

@export var acceleration: float = 800.0
@export var rotation_speed: float = 8.0

# ===== MOVEMENT STATE =====
var owner_ship: MiniShip = null
var owner_player: Player = null
var current_state: ShipState = ShipState.FIND_TARGET

var velocity: Vector2 = Vector2.ZERO
var desired_velocity: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO

# ===== INITIALIZATION =====
func initialize(ship: MiniShip, player: Player) -> void:
	owner_ship = ship
	owner_player = player
	current_state = ShipState.FIND_TARGET

# ===== MOVEMENT UPDATE =====
func update_movement(delta: float) -> void:
	if not is_instance_valid(owner_player):
		return
	
	_update_state_machine(delta)
	_calculate_movement()
	
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	owner_ship.position += velocity * delta
	
	if velocity.length() > 20.0:
		var target_rotation = velocity.angle()
		owner_ship.rotation = lerp_angle(owner_ship.rotation, target_rotation, rotation_speed * delta)

func _update_state_machine(delta: float) -> void:
	var distance_to_player = owner_ship.global_position.distance_to(owner_player.global_position)
	
	# Get current target from ship's TargetSelector
	var current_target = owner_ship.get_current_target()
	
	if distance_to_player > max_range_from_player:
		if current_state != ShipState.RETURN_TO_RANGE:
			current_state = ShipState.RETURN_TO_RANGE
		return
	
	match current_state:
		ShipState.RETURN_TO_RANGE:
			if distance_to_player < comfort_range:
				current_state = ShipState.FIND_TARGET
		
		ShipState.FIND_TARGET:
			if current_target:
				current_state = ShipState.ENGAGE_TARGET
		
		ShipState.ENGAGE_TARGET:
			if not current_target:
				current_state = ShipState.FIND_TARGET

func _calculate_movement() -> void:
	match current_state:
		ShipState.RETURN_TO_RANGE:
			_move_to_player()
		ShipState.FIND_TARGET:
			_patrol_movement()
		ShipState.ENGAGE_TARGET:
			_combat_movement()

func _move_to_player() -> void:
	var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
	target_position = owner_player.global_position + offset
	
	var direction = (target_position - owner_ship.global_position).normalized()
	desired_velocity = direction * return_speed

func _patrol_movement() -> void:
	var to_player = owner_player.global_position - owner_ship.global_position
	var distance = to_player.length()
	
	if distance > comfort_range * 0.8:
		desired_velocity = to_player.normalized() * cruise_speed
	else:
		var tangent = Vector2(-to_player.y, to_player.x).normalized()
		desired_velocity = tangent * cruise_speed * 0.5
		desired_velocity += to_player.normalized() * cruise_speed * 0.2

func _combat_movement() -> void:
	var current_target = owner_ship.get_current_target()
	if not current_target or not is_instance_valid(current_target):
		return
	
	var to_target = current_target.global_position - owner_ship.global_position
	var distance = to_target.length()
	
	if distance > attack_range * 1.2:
		desired_velocity = to_target.normalized() * combat_speed
	elif distance < attack_range * 0.8:
		desired_velocity = -to_target.normalized() * combat_speed * 0.7
	else:
		var tangent = Vector2(-to_target.y, to_target.x).normalized()
		if randf() < 0.02:
			tangent *= -1
		desired_velocity = tangent * combat_speed * 0.8

# ===== GETTERS FOR SHIP =====
func get_current_target() -> Node:
	# Movement no longer tracks targets - get from ship's TargetSelector
	return owner_ship.get_current_target() if owner_ship else null

func get_current_state() -> ShipState:
	return current_state

func get_current_state_name() -> String:
	match current_state:
		ShipState.RETURN_TO_RANGE: return "Returning"
		ShipState.FIND_TARGET: return "Searching"
		ShipState.ENGAGE_TARGET: return "Engaging"
		_: return "Unknown"

func get_debug_info() -> Dictionary:
	var current_target = get_current_target()
	return {
		"state": get_current_state_name(),
		"target": current_target.name if current_target else "None",
		"velocity": velocity.length(),
		"distance_to_player": owner_ship.global_position.distance_to(owner_player.global_position) if owner_player else 0
	}
