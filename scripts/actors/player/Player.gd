extends "res://scripts/actors/Actor.gd"
class_name Player

# ───── Dependencies ─────
var player_data : PlayerData = null   # injected

# ───── Sub-systems ─────
@onready var blink_system   : BlinkSystem   = $BlinkSystem
@onready var weapon_system  : WeaponSystem  = $WeaponSystem
@onready var movement_system: PlayerMovement = $PlayerMovement

# ───── State ─────
var shoot_cooldown_timer : float = 0.0
var fire_interval        : float = 0.5

# ───── Init ─────
func initialize(p_data: PlayerData) -> void:
	player_data = p_data
	add_to_group("Player")
	collision_layer = 1 << 1
	collision_mask  = 0

	max_health           = player_data.get_stat("max_hp")
	health               = player_data.hp
	max_shield           = player_data.get_stat("max_shield")
	shield               = player_data.shield
	shield_recharge_rate = player_data.get_stat("shield_recharge_rate")
	speed                = player_data.get_stat("speed")

	_update_attack_timing()

	blink_system.initialize(self, player_data)
	weapon_system.owner_player  = self
	movement_system.initialize(self)

# ───── Physics loop ─────
func _physics_process(delta: float) -> void:
	movement_system.physics_step(delta)
	_auto_fire_weapons(delta)

# ───── Shooting ─────
func _update_attack_timing() -> void:
	fire_interval = 1.0 / (
		player_data.get_stat("base_fire_rate") *
		player_data.get_stat("attack_speed")    # (bullet-only in future)
	)

func _auto_fire_weapons(delta: float) -> void:
	shoot_cooldown_timer -= delta
	if shoot_cooldown_timer > 0:
		return
	weapon_system.auto_fire(delta)
	shoot_cooldown_timer = fire_interval

# ───── Weapon wrappers (unchanged API) ─────
func get_weapon_slot(i:int) -> Node:       return weapon_system.get_slot(i)
func clear_all_weapons()  -> void:         weapon_system.clear_all()
func equip_weapon(s:PackedScene,i:int)->void: weapon_system.equip(s,i)

# ───── Per-level reset ─────
func reset_per_level() -> void:
	health  = player_data.get_stat("max_hp")
	shield  = player_data.get_stat("max_shield")
	blink_system.initialize(self, player_data)
	player_data.current_rerolls = int(player_data.get_stat("rerolls_per_wave"))
