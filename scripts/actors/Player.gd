extends "res://scripts/actors/Actor.gd"
class_name Player

@onready var shoot_bar = $ShootBarUI/Bar

@export var crit_chance: float = 5.0
@export var luck: float = 1.0
@export var weapon_range: float = 500.0
@export var piercing: int = 0
@export var blink_cooldown: float = 5.0

@export var base_fire_rate: float = 2.0
@export var attack_speed: float = 1.0

@export var invulnerability_duration: float = 0.2
var is_invulnerable: bool = false
var invuln_timer: float = 0.0

var fire_interval: float = 0.5
var stop_to_shoot_delay: float = 0.2

var shoot_ready_timer: float = 0.0
var shoot_cooldown_timer: float = 0.0

var blink_timer: float = 0.0
var target_position: Vector2
var is_stopped: bool = false

# Buffer system for smart movement after stop
var buffered_target: Vector2
var has_buffered_click: bool = false
var stop_buffer_timer: float = 0.0
const STOP_BUFFER_LIFETIME := 0.2

func _ready() -> void:
	add_to_group("Player")
	health = 100
	max_health = 100
	shield = 50
	max_shield = 50
	shield_recharge_rate = 5.0
	speed = 200.0
	target_position = global_position
	_update_attack_timing()

func _update_attack_timing():
	fire_interval = 1.0 / (base_fire_rate * attack_speed)
	stop_to_shoot_delay = clamp(0.4 / attack_speed, 0.1, 0.4)

func _physics_process(delta: float) -> void:
	_update_shoot_bar()
	_handle_blink_cooldown(delta)
	_handle_invulnerability(delta)
	_handle_movement(delta)
	_auto_fire_weapons(delta)

func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if is_stopped:
			buffered_target = get_global_mouse_position()
			has_buffered_click = true
			stop_buffer_timer = 0.0
		else:
			target_position = get_global_mouse_position()

	elif event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_S:
					stop()
				KEY_F:
					_try_blink()
		else:
			if event.keycode == KEY_S:
				unstop()

func _handle_blink_cooldown(delta: float) -> void:
	if blink_timer < blink_cooldown:
		blink_timer += delta

func _handle_invulnerability(delta: float) -> void:
	if is_invulnerable:
		invuln_timer -= delta
		if invuln_timer <= 0:
			is_invulnerable = false

func _handle_movement(delta: float) -> void:
	if is_stopped:
		velocity = Vector2.ZERO
		if has_buffered_click:
			stop_buffer_timer += delta
			if stop_buffer_timer > STOP_BUFFER_LIFETIME:
				has_buffered_click = false
		shoot_ready_timer = 0.0
		return

	if global_position.distance_squared_to(target_position) > 4:
		var dir = (target_position - global_position).normalized()
		move(dir, delta)
		shoot_ready_timer = 0.0
	else:
		velocity = Vector2.ZERO
		shoot_ready_timer += delta

func _try_blink() -> void:
	if blink_timer >= blink_cooldown:
		blink_to_position(get_global_mouse_position())
		blink_timer = 0.0

func blink_to_position(pos: Vector2) -> void:
	global_position = pos
	target_position = pos
	velocity = Vector2.ZERO

func stop() -> void:
	is_stopped = true
	target_position = global_position
	velocity = Vector2.ZERO
	has_buffered_click = false
	stop_buffer_timer = 0.0

func unstop() -> void:
	is_stopped = false
	stop_buffer_timer = 0.0
	if has_buffered_click:
		target_position = buffered_target
		has_buffered_click = false

func _update_shoot_bar() -> void:
	var fill = clamp(shoot_ready_timer / stop_to_shoot_delay, 0.0, 1.0)
	shoot_bar.value = fill


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
		push_error("Weapon slot %d not found" % slot_index)
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
	shoot_cooldown_timer -= delta

	if velocity.length() > 0 or shoot_ready_timer < stop_to_shoot_delay:
		return

	for i in 6:
		var slot = get_weapon_slot(i)
		if slot:
			for child in slot.get_children():
				if child.has_method("auto_fire") and shoot_cooldown_timer <= 0:
					child.auto_fire(delta)
					shoot_cooldown_timer = fire_interval

func receive_damage(amount: int) -> void:
	if is_invulnerable:
		return
	take_damage(amount)
	is_invulnerable = true
	invuln_timer = invulnerability_duration
