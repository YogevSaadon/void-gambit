# scripts/weapons/ship/BaseShipWeapon.gd
extends Node2D
class_name BaseShipWeapon

# ===== SHIP WEAPON STATS =====
@export var base_damage: float = 10.0
@export var base_fire_rate: float = 1.0
@export var base_crit_chance: float = 0.0

# ===== CONFIGURED STATS (set by spawner) =====
var final_damage: float = 0.0
var final_fire_rate: float = 0.0
var final_crit_chance: float = 0.0

# ===== TARGETING =====
var forced_target: Node = null  # Target assigned by ship
var cooldown_timer: float = 0.0

# ===== REFERENCES =====
var owner_ship: MiniShip = null
@onready var muzzle: Node2D = get_node_or_null("Muzzle")

# ===== LIFECYCLE =====
func _ready() -> void:
	# Ensure we have a muzzle
	if not muzzle:
		push_warning("BaseShipWeapon: No Muzzle node found, creating default")
		muzzle = Node2D.new()
		muzzle.name = "Muzzle"
		muzzle.position = Vector2(7, 0)  # Default forward position
		add_child(muzzle)

func _physics_process(delta: float) -> void:
	_update_weapon(delta)

# ===== MAIN WEAPON UPDATE =====
func _update_weapon(delta: float) -> void:
	# Update cooldown
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
	
	# Aim at target if we have one
	if forced_target and is_instance_valid(forced_target):
		_aim_at_target(forced_target)
		
		# Fire if ready
		if cooldown_timer <= 0.0:
			_fire_at_target(forced_target)
			cooldown_timer = 1.0 / final_fire_rate

func _aim_at_target(target: Node) -> void:
	"""Rotate weapon to face target"""
	if not muzzle:
		return
	
	var direction = (target.global_position - muzzle.global_position).normalized()
	rotation = direction.angle()

# ===== WEAPON CONFIGURATION =====
func configure_weapon(damage: float, fire_rate: float, crit_chance: float) -> void:
	"""Called by spawner to set weapon stats"""
	final_damage = damage
	final_fire_rate = fire_rate
	final_crit_chance = crit_chance

func set_owner_ship(ship: MiniShip) -> void:
	"""Set the ship that owns this weapon"""
	owner_ship = ship

func set_forced_target(target: Node) -> void:
	"""Set target from ship AI"""
	forced_target = target

# ===== FIRING METHODS (Override in child classes) =====
func _fire_at_target(target: Node) -> void:
	"""Override this in child classes to implement specific weapon behavior"""
	push_warning("BaseShipWeapon: _fire_at_target() not implemented in %s" % get_script().get_path())

# ===== UTILITY METHODS =====
func get_muzzle_position() -> Vector2:
	"""Get world position where projectiles should spawn"""
	if muzzle:
		return muzzle.global_position
	return global_position

func get_direction_to_target(target: Node) -> Vector2:
	"""Get normalized direction from muzzle to target"""
	if not target:
		return Vector2.RIGHT
	return (target.global_position - get_muzzle_position()).normalized()

func is_target_valid() -> bool:
	"""Check if current forced target is valid"""
	return forced_target and is_instance_valid(forced_target)

# ===== DEBUG INFO =====
func get_weapon_debug_info() -> Dictionary:
	"""Get debug information about weapon state"""
	return {
		"weapon_type": get_script().get_path().get_file().get_basename(),
		"damage": final_damage,
		"fire_rate": final_fire_rate,
		"crit_chance": final_crit_chance,
		"cooldown": "%.2fs" % cooldown_timer,
		"target": forced_target.name if forced_target else "None",
		"target_valid": is_target_valid()
	}
