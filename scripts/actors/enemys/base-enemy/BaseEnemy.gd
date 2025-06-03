# /scripts/actors/enemys/base-enemy/BaseEnemy.gd
extends "res://scripts/actors/Actor.gd"
class_name BaseEnemy

signal died

# ──────────────────────────────
# 1.  Enemy metadata (code-set)
# ──────────────────────────────
@export var power_level: int = 1
@export var rarity      : String = "common"
@export_range(1,100) var min_level : int = 1
@export_range(1,100) var max_level : int = 5

## Plug-in scripts set in subclasses
var movement_script : Script
var attack_script   : Script

# ──────────────────────────────
# 2.  Internal (runtime)
# ──────────────────────────────
var _move_logic  : Node = null
var _attack_logic: Node = null

var _base_max_hp      : int
var _base_shield      : int
var _base_speed       : float
var _base_recharge    : float

@onready var _damage_anchor : Node2D = $DamageAnchor
@onready var _power_rect    : ColorRect = $"PowerIndicator/ColorRect"
@onready var _status_comp   : Node = $StatusComponent if has_node("StatusComponent") else null
@onready var _pd            : PlayerData = get_tree().root.get_node("PlayerData")

# ──────────────────────────────
# 3.  Early init
# ──────────────────────────────
func _enter_tree() -> void:
	# Cache the designer-defined base stats **before** scaling
	_base_max_hp     = max_health
	_base_shield     = max_shield
	_base_speed      = speed
	_base_recharge   = shield_recharge_rate

	_set_final_stats()        # compute stats once
	_spawn_components()       # movement / attack scripts

	# Default layers / group
	collision_layer = 1 << 2
	collision_mask  = (1 << 1) | (1 << 4)
	add_to_group("Enemies")

func _ready() -> void:
	_update_power_color()

# ──────────────────────────────
# 4.  Public setters
# ──────────────────────────────
func set_power_level(v:int) -> void:
	power_level = max(1, v)
	_set_final_stats()
	_update_power_color()

# ──────────────────────────────
# 5.  Stat handling
# ──────────────────────────────
func _set_final_stats() -> void:
	max_health           = _base_max_hp   * power_level
	health               = max_health
	max_shield           = _base_shield   * power_level
	shield               = max_shield
	speed                = _base_speed    * power_level
	shield_recharge_rate = _base_recharge * power_level

func _update_power_color() -> void:
	if not _power_rect: return
	var c := Color.WHITE
	match power_level:
		1:  c = Color(1,1,1)
		2:  c = Color(0,1,0)
		4:  c = Color(0.2,0.6,1)
		_:  c = Color(0.6,0,1)
	_power_rect.color = c

# ──────────────────────────────
# 6.  Component plug-ins
# ──────────────────────────────
func _spawn_components() -> void:
	if movement_script:
		_move_logic = movement_script.new()
		add_child(_move_logic)
		_move_logic.enemy = self

	if attack_script:
		_attack_logic = attack_script.new()
		add_child(_attack_logic)
		_attack_logic.enemy = self

# ──────────────────────────────
# 7.  Per-frame
# ──────────────────────────────
func _physics_process(delta:float)->void:
	if _move_logic   and _move_logic.has_method("tick_movement"):
		_move_logic.tick_movement(delta)
	if _attack_logic and _attack_logic.has_method("tick_attack"):
		_attack_logic.tick_attack(delta)

# ──────────────────────────────
# 8.  Damage & death
# ──────────────────────────────
func apply_damage(amount:float, is_crit:bool)->void:
	var dmg = amount * (_pd.get_stat("crit_damage") if is_crit else 1.0)
	_show_number(dmg, is_crit)
	take_damage(dmg)

func _show_number(amount:float, is_crit:bool) -> void:
	var dn := preload("res://scripts/ui/DamageNumber.gd").new()
	_damage_anchor.add_child(dn)
	dn.add_damage(amount, is_crit)

func on_death() -> void:
	if _status_comp and _status_comp.has_method("clear_all"):
		_status_comp.clear_all()
	emit_signal("died")
	queue_free()
