# scripts/weapons/spawners/MiniShip.gd
extends Node2D
class_name MiniShip

# ===== COMPONENTS =====
var movement_component: Node = null  # Will be MiniShipMovement
var targeting_component: Node = null  # Will be TargetSelector
var current_weapon: BaseShipWeapon = null
var owner_player: Player = null

func _ready() -> void:
	add_to_group("PlayerShips")
	
	# FIXED: Use WeaponSlot instead of WeaponAttachment to match the scene
	if not has_node("WeaponSlot"):
		var slot = Node2D.new()
		slot.name = "WeaponSlot"
		add_child(slot)
	
	# Create movement component
	if not has_node("Movement"):
		movement_component = preload("res://scripts/weapons/spawners/MiniShipMovement.gd").new()
		movement_component.name = "Movement"
		add_child(movement_component)
	else:
		movement_component = get_node("Movement")
	
	# Create targeting component
	if not has_node("TargetSelector"):
		targeting_component = preload("res://scripts/weapons/spawners/TargetSelector.gd").new()
		targeting_component.name = "TargetSelector"
		add_child(targeting_component)
	else:
		targeting_component = get_node("TargetSelector")
	
	if owner_player:
		global_position = owner_player.global_position
		if movement_component:
			movement_component.initialize(self, owner_player)
		if targeting_component:
			targeting_component.initialize(self)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(owner_player):
		queue_free()
		return
	
	# Update targeting first
	if targeting_component:
		targeting_component.update_targeting(delta)
	
	# Delegate movement to movement component
	if movement_component:
		movement_component.update_movement(delta)
	
	_update_weapon_target()

func setup_weapon(weapon: BaseShipWeapon) -> void:
	if not weapon:
		push_error("MiniShip: Null weapon passed to setup_weapon!")
		return
	
	current_weapon = weapon
	# FIXED: Use WeaponSlot instead of WeaponAttachment
	var weapon_slot = get_node_or_null("WeaponSlot")
	if weapon_slot:
		weapon_slot.add_child(weapon)
		weapon.set_owner_ship(self)
		print("MiniShip: Weapon attached successfully to WeaponSlot")
	else:
		push_error("MiniShip: WeaponSlot node not found!")

func _update_weapon_target() -> void:
	if current_weapon and is_instance_valid(current_weapon) and targeting_component:
		var current_target = targeting_component.get_current_target()
		current_weapon.set_forced_target(current_target)

func set_owner_player(player: Player) -> void:
	owner_player = player
	if owner_player:
		global_position = owner_player.global_position
		if movement_component:
			movement_component.initialize(self, owner_player)
		if targeting_component:
			targeting_component.initialize(self)

# ===== GETTERS (Delegate to components) =====
func get_current_target() -> Node:
	if targeting_component:
		return targeting_component.get_current_target()
	return null

func get_current_state_name() -> String:
	if movement_component:
		return movement_component.get_current_state_name()
	return "No Movement"

func get_debug_info() -> Dictionary:
	var info = {}
	if movement_component:
		info["movement"] = movement_component.get_debug_info()
	if targeting_component:
		info["targeting"] = targeting_component.get_debug_info()
	return info

func _exit_tree() -> void:
	if current_weapon:
		current_weapon.queue_free()
	current_weapon = null
	owner_player = null
