# /scripts/enemies/base_enemy/BaseEnemy.gd
extends "res://scripts/actors/Actor.gd"
class_name BaseEnemy

signal died

# ────────── 1 · Metadata & Touch-Damage ──────────────────────────────────
@export var power_level      : int    = 1
@export var rarity           : String = "common"
@export_range(1,100) var min_level : int = 1
@export_range(1,100) var max_level : int = 5

@export var damage           : int    = 10       # per-tick at power-1
@export var damage_interval  : float  = 1.0      # seconds between ticks

var movement_script : Script           # set by concrete enemy
var attack_script   : Script           # optional ranged plug-in

# ────────── 2 · Internals ────────────────────────────────────────────────
var _move_logic     : Node  = null
var _attack_logic   : Node  = null
var _dmg_timer      : float = 0.0
var _player_in_zone : Node  = null
var _active_dn      : DamageNumber = null

var _base_hp  : int
var _base_sh  : int
var _base_spd : float
var _base_reg : float
var _base_dmg : int                              # FIX #1

@onready var _anchor  : Node2D     = $DamageAnchor
@onready var _status  : Node       = $StatusComponent if has_node("StatusComponent") else null
@onready var _pd      : PlayerData = get_tree().root.get_node("PlayerData")
@onready var _drop_sc               := preload("res://scenes/drops/CreditDrop.tscn")
@onready var _power_ind : Node      = $"PowerIndicator" if has_node("PowerIndicator") else null

# ────────── 3 · Early Init ───────────────────────────────────────────────
func _enter_tree() -> void:
	_base_hp   = max_health
	_base_sh   = max_shield
	_base_spd  = speed
	_base_reg  = shield_recharge_rate
	_base_dmg  = damage                        # FIX #1

	_apply_power_scale()
	_spawn_plugins()
	_setup_physics()
	_connect_damage_zone()

func _ready() -> void:
	if _power_ind and _power_ind.has_method("apply_power_level"):
		_power_ind.apply_power_level(power_level)

# ────────── 4 · Helpers ─────────────────────────────────────────────────
func _apply_power_scale() -> void:
	max_health           = _base_hp  * power_level
	health               = max_health
	max_shield           = _base_sh  * power_level
	shield               = max_shield
	speed                = _base_spd * power_level
	shield_recharge_rate = _base_reg * power_level
	damage               = _base_dmg * power_level        # no inflation

func _spawn_plugins() -> void:
	if movement_script:
		_move_logic = movement_script.new()
		_move_logic.enemy = self                         # FIX #2
		add_child(_move_logic)
	if attack_script:
		_attack_logic = attack_script.new()
		_attack_logic.enemy = self                       # FIX #2
		add_child(_attack_logic)

func _setup_physics() -> void:
	collision_layer = 1 << 2        # Enemies
	collision_mask  = 1 << 2        # repel only enemies
	add_to_group("Enemies")

# ────────── 4b · Wire DamageZone (all code) ─────────────────────────────
func _connect_damage_zone() -> void:
	if not has_node("DamageZone"):
		push_error("%s: DamageZone Area2D missing!" % name)
		return

	var zone : Area2D = $DamageZone
	zone.collision_layer = collision_layer
	zone.collision_mask  = 1 << 1                   # FIX #4 (always player bit)

	if zone.get_child_count() == 0 or \
	   not (zone.get_child(0) is CollisionShape2D):
		var cs := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 24
		cs.shape = circle
		zone.add_child(cs)

	if not zone.body_entered.is_connected(_on_zone_entered):   # FIX #3
		zone.body_entered.connect(_on_zone_entered)
		zone.body_exited .connect(_on_zone_exited)

# ────────── 5 · Touch-Damage Tick ───────────────────────────────────────
func _on_zone_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		_player_in_zone = body
		_dmg_timer = 0.0

func _on_zone_exited(body: Node) -> void:
	if body == _player_in_zone:
		_player_in_zone = null

# ────────── 6 · Main Loop ───────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if _move_logic and _move_logic.has_method("tick_movement"):
		_move_logic.tick_movement(delta)
	if _attack_logic and _attack_logic.has_method("tick_attack"):
		_attack_logic.tick_attack(delta)

	recharge_shield(delta)

	if _player_in_zone:
		_dmg_timer -= delta
		if _dmg_timer <= 0.0:
			_player_in_zone.receive_damage(damage)
			_dmg_timer = damage_interval

# ────────── 7 · Taking Damage ───────────────────────────────────────────
func apply_damage(amount: float, is_crit: bool) -> void:
	if _pd == null: return                             # FIX #5
	var dmg = amount * (_pd.get_stat("crit_damage") if is_crit else 1.0)
	_show_number(dmg, is_crit)
	take_damage(dmg)

func _show_number(amount: float, is_crit: bool) -> void:
	if _active_dn and is_instance_valid(_active_dn):
		if _active_dn.is_detached: _active_dn = null
		else:
			_active_dn.add_damage(amount, is_crit); return
	_active_dn = preload("res://scripts/ui/DamageNumber.gd").new()
	_anchor.add_child(_active_dn)
	_active_dn.add_damage(amount, is_crit)

# ────────── 8 · Death Flow ──────────────────────────────────────────────
func on_death() -> void:
	if _active_dn and is_instance_valid(_active_dn):
		_active_dn.detach()
	if _status and _status.has_method("clear_all"):
		_status.clear_all()

	var credit := _drop_sc.instantiate()
	credit.global_position = global_position
	credit.value = power_level
	get_tree().current_scene.add_child(credit)

	emit_signal("died")
	queue_free()
