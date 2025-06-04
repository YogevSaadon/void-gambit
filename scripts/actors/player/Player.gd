extends "res://scripts/actors/Actor.gd"
class_name Player

# ───── Dependencies (injected) ─────
var player_data : PlayerData = null

# ───── Sub-systems ─────
@onready var blink_system    : BlinkSystem     = $BlinkSystem
@onready var weapon_system   : WeaponSystem    = $WeaponSystem
@onready var movement_system : PlayerMovement  = $PlayerMovement

# ─────  i-frame state ─────
var invuln_timer : float = 0.0        # counts down each frame
const INVULN_TIME := 0.3              # 300 ms of invulnerability

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

	blink_system.initialize(self, player_data)
	weapon_system.owner_player  = self
	movement_system.initialize(self)

# ───── Physics loop ─────
func _physics_process(delta: float) -> void:
	invuln_timer = max(invuln_timer - delta, 0.0)
	movement_system.physics_step(delta)
	weapon_system.auto_fire(delta)

# ───── Damage intake ─────
func receive_damage(amount: int) -> void:
	if invuln_timer > 0.0:
		return          

	take_damage(amount)   
	invuln_timer = INVULN_TIME
	_flash_invuln()

	if health <= 0:
		queue_free()       # TODO: hook GameManager death flow

func _flash_invuln() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.2, 0.05)
	tw.tween_property(self, "modulate:a", 1.0, 0.05)

# ───── Weapon helpers ─────
func get_weapon_slot(i:int)            -> Node: return weapon_system.get_slot(i)
func clear_all_weapons()               -> void: weapon_system.clear_all()
func equip_weapon(s:PackedScene, i:int)-> void: weapon_system.equip(s, i)

# ───── Per-level reset ─────
func reset_per_level() -> void:
	health  = player_data.get_stat("max_hp")
	shield  = player_data.get_stat("max_shield")
	blink_system.initialize(self, player_data)
