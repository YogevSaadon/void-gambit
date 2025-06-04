extends "res://scripts/actors/Actor.gd"
class_name BaseEnemy

# Emits when this enemy dies (WaveManager can listen)
signal died

# ───── 1 · Designer-editable metadata ───────────────────────────────────
@export var power_level      : int    = 1
@export var rarity           : String = "common"
@export_range(1,100) var min_level : int = 1
@export_range(1,100) var max_level : int = 5

# Contact-damage defaults (used by ContactDamage.gd)
@export var damage           : int    = 10     # per tick @ power-1
@export var damage_interval  : float  = 1.0    # seconds between ticks

# ───── 2 · Cached base stats (filled once in _enter_tree) ───────────────
var _base_hp   : int
var _base_sh   : int
var _base_spd  : float
var _base_reg  : float
var _base_dmg  : int                           # cached unscaled damage

# References discovered in _ready()
var _move_logic   : Node = null
var _attack_logic : Node = null

# ───── 3 · Helper nodes / singletons ────────────────────────────────────
@onready var _anchor     : Node2D      = $DamageAnchor
@onready var _status     : Node        = $StatusComponent if has_node("StatusComponent") else null
@onready var _pd         : PlayerData  = get_tree().root.get_node("PlayerData")
@onready var _drop_scene : PackedScene = preload("res://scenes/drops/CreditDrop.tscn")
@onready var _power_ind  : Node        = $"PowerIndicator" if has_node("PowerIndicator") else null

# ───── 4 · Lifecycle ───────────────────────────────────────────────────
func _enter_tree() -> void:
	# Cache designer (power-1) stats
	_base_hp   = max_health
	_base_sh   = max_shield
	_base_spd  = speed
	_base_reg  = shield_recharge_rate
	_base_dmg  = damage

	_apply_power_scale()
	_setup_physics()

func _ready() -> void:
	# Discover first child implementing tick_movement / tick_attack
	for c in get_children():
		if _move_logic == null   and c.has_method("tick_movement"):
			_move_logic = c
		elif _attack_logic == null and c.has_method("tick_attack"):
			_attack_logic = c

	if _power_ind and _power_ind.has_method("apply_power_level"):
		_power_ind.apply_power_level(power_level)

# ───── 5 · Helper methods ───────────────────────────────────────────────
func _apply_power_scale() -> void:
	max_health           = _base_hp  * power_level
	health               = max_health
	max_shield           = _base_sh  * power_level
	shield               = max_shield
	speed                = _base_spd * power_level
	shield_recharge_rate = _base_reg * power_level
	damage               = _base_dmg * power_level        # scaled for ContactDamage

func _setup_physics() -> void:
	collision_layer = 1 << 2       # Enemies
	collision_mask  = 1 << 2       # repel other enemies only
	add_to_group("Enemies")

# ───── 6 · Per-frame loop ───────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if _move_logic   and _move_logic.has_method("tick_movement"):
		_move_logic.tick_movement(delta)
	if _attack_logic and _attack_logic.has_method("tick_attack"):
		_attack_logic.tick_attack(delta)

	recharge_shield(delta)

# ───── 7 · Damage intake & floating numbers ─────────────────────────────
func apply_damage(amount: float, is_crit: bool) -> void:
	# Protect against running this scene stand-alone
	if _pd == null:
		return
	var dmg := amount * (_pd.get_stat("crit_damage") if is_crit else 1.0)
	_show_damage_number(dmg, is_crit)
	take_damage(dmg)

func _show_damage_number(value: float, crit: bool) -> void:
	var dn := preload("res://scripts/ui/DamageNumber.gd").new()
	_anchor.add_child(dn)
	dn.add_damage(value, crit)

# ───── 8 · Death flow & credit drop ─────────────────────────────────────
func on_death() -> void:
	if _status and _status.has_method("clear_all"):
		_status.clear_all()

	var credit := _drop_scene.instantiate()
	credit.global_position = global_position
	credit.value = power_level
	get_tree().current_scene.add_child(credit)

	emit_signal("died")
	queue_free()
