extends "res://scripts/actors/Actor.gd"
class_name Player

@export var crit_chance: float = 5.0
@export var luck: float = 1.0
@export var weapon_range: float = 500.0
@export var piercing: int = 0
@export var blink_cooldown: float = 5.0

var blink_timer: float = 0.0
var target_position: Vector2

func _ready() -> void:
	add_to_group("Player")

	health = 100
	max_health = 100
	shield = 50
	max_shield = 50
	shield_recharge_rate = 5.0
	speed = 200.0
	target_position = global_position

func _physics_process(delta: float) -> void:
	_handle_blink_cooldown(delta)
	_handle_movement(delta)
	_auto_fire_weapons(delta)

func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		target_position = get_global_mouse_position()
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F:
				_try_blink()
			KEY_S:
				stop()

func _handle_blink_cooldown(delta: float) -> void:
	if blink_timer < blink_cooldown:
		blink_timer += delta

func _handle_movement(delta: float) -> void:
	if global_position.distance_to(target_position) > 3.0:
		var dir = (target_position - global_position).normalized()
		move(dir, delta)
	else:
		velocity = Vector2.ZERO

func _try_blink() -> void:
	if blink_timer >= blink_cooldown:
		blink_to_position(get_global_mouse_position())
		blink_timer = 0.0

func blink_to_position(pos: Vector2) -> void:
	global_position = pos
	target_position = pos
	velocity = Vector2.ZERO

func stop() -> void:
	target_position = global_position
	velocity = Vector2.ZERO

# ====== Weapon Management ======

func get_weapon_slot(index: int) -> Node:
	match index:
		0: return $WeaponSlots/Weapon0
		1: return $WeaponSlots/Weapon1
		2: return $WeaponSlots/Weapon2
		3: return $WeaponSlots/Weapon3
		4: return $WeaponSlots/Weapon4
		5: return $WeaponSlots/Weapon5
		_: return null

func clear_all_weapons() -> void:
	for i in 6:
		var slot = get_weapon_slot(i)
		if slot:
			for child in slot.get_children():
				child.queue_free()

func equip_weapon(scene: PackedScene, slot_index: int) -> void:
	var slot = get_weapon_slot(slot_index)
	if slot == null:
		push_error("❌ Weapon slot %d not found!" % slot_index)
		return

	var weapon = scene.instantiate()
	weapon.owner_player = self

	if weapon.has_method("apply_weapon_modifiers"):
		weapon.apply_weapon_modifiers({
			"crit": crit_chance,
			"piercing": piercing,
			"range": weapon_range
		})

	slot.add_child(weapon)

func _auto_fire_weapons(delta: float) -> void:
	if velocity.length() > 0:
		return  # only fire when standing still

	for i in 6:
		var slot = get_weapon_slot(i)
		if slot:
			for child in slot.get_children():
				if child.has_method("auto_fire"):
					child.auto_fire(delta)
