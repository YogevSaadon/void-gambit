extends "res://scripts/actors/Actor.gd"
class_name Player

# ====== Dependencies (Injected) ======
var player_data: PlayerData = null  # Must be set from Level.gd

# ====== Constants ======
const MOVE_STOP_THRESHOLD_SQUARED := 4.0

# ====== Runtime State ======
@onready var shoot_bar := $ShootBarUI/Bar
@onready var blink_system := $BlinkSystem

var target_position: Vector2
var is_stopped: bool = false

var shoot_ready_timer: float = 0.0
var shoot_cooldown_timer: float = 0.0

var fire_interval: float = 0.5
var stop_to_shoot_delay: float = 0.2

# ====== Initialization ======
func initialize(p_data: PlayerData) -> void:
	player_data = p_data
	add_to_group("Player")
	collision_layer = 1 << 1
	collision_mask = 0

	max_health           = player_data.get_stat("max_hp")
	health               = player_data.hp
	max_shield           = player_data.get_stat("max_shield")
	shield               = player_data.shield
	shield_recharge_rate = player_data.get_stat("shield_recharge_rate")
	speed                = player_data.get_stat("speed")

	target_position = global_position
	_update_attack_timing()

	blink_system.initialize(self, player_data)

# ====== Movement ======
func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_update_shoot_bar()
	_auto_fire_weapons(delta)

func _handle_movement(delta: float) -> void:
	if is_stopped:
		velocity = Vector2.ZERO
		shoot_ready_timer += delta
		return

	if global_position.distance_squared_to(target_position) > MOVE_STOP_THRESHOLD_SQUARED:
		var dir = (target_position - global_position).normalized()
		move(dir, delta)
		shoot_ready_timer = 0.0
	else:
		velocity = Vector2.ZERO
		shoot_ready_timer += delta

func _input(event) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_S:
				if not is_stopped:
					is_stopped = true
					target_position = global_position
			KEY_F:
				blink_system.try_blink(get_global_mouse_position())
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		is_stopped = false
		target_position = get_global_mouse_position()

# ====== Shooting ======
func _update_attack_timing() -> void:
	fire_interval = 1.0 / (
		player_data.get_stat("base_fire_rate") *
		player_data.get_stat("attack_speed")
	)
	stop_to_shoot_delay = clamp(0.4 / player_data.get_stat("attack_speed"), 0.1, 0.4)

func _update_shoot_bar() -> void:
	var fill = pow(clamp(shoot_ready_timer / stop_to_shoot_delay, 0.0, 1.0), 0.8)
	shoot_bar.value = fill
	shoot_bar.visible = (fill < 1.0 and velocity.length() == 0)

func _auto_fire_weapons(delta: float) -> void:
	shoot_cooldown_timer -= delta
	if shoot_cooldown_timer > 0 or velocity.length() > 0 or shoot_ready_timer < stop_to_shoot_delay:
		return

	for i in 6:
		var slot = get_weapon_slot(i)
		if slot:
			for child in slot.get_children():
				child.auto_fire(delta)
				shoot_cooldown_timer = fire_interval

# ====== Weapons ======
func get_weapon_slot(index: int) -> Node:
	return get_node("WeaponSlots/Weapon%d" % index)

func clear_all_weapons() -> void:
	for i in 6:
		var slot = get_weapon_slot(i)
		if slot:
			for child in slot.get_children():
				child.queue_free()

func equip_weapon(scene: PackedScene, slot_index: int) -> void:
	if scene == null:
		push_error("Attempted to equip a null weapon scene in slot %d" % slot_index)
		return

	var slot = get_weapon_slot(slot_index)
	if slot == null:
		push_error("Weapon slot %d not found" % slot_index)
		return

	var weapon = scene.instantiate()
	weapon.owner_player = self
	weapon.apply_weapon_modifiers(player_data)
	slot.add_child(weapon)

# ====== Other ======
func reset_per_level() -> void:
	health = player_data.get_stat("max_hp")
	shield = player_data.get_stat("max_shield")
	blink_system.initialize(self, player_data)
	player_data.current_rerolls = int(player_data.get_stat("rerolls_per_wave"))
