# BaseEnemy.gd
extends "res://scripts/actors/Actor.gd"
class_name BaseEnemy

signal died

@export var power_level: int = 1
@export var rarity: String = "common"
@export_range(1, 100) var min_level: int = 1
@export_range(1, 100) var max_level: int = 10

@export var movement_script: Script
@export var attack_script: Script

var movement_logic: Node = null
var attack_logic: Node = null

@onready var damage_anchor: Node2D = $DamageAnchor
@onready var status_component: Node = $StatusComponent if has_node("StatusComponent") else null
@onready var pd: Node = get_tree().root.get_node("PlayerData")

func _ready() -> void:
	add_to_group("Enemies")
	_initialize_components()

func _initialize_components() -> void:
	if movement_script:
		movement_logic = movement_script.new()
		add_child(movement_logic)
		movement_logic.enemy = self

	if attack_script:
		attack_logic = attack_script.new()
		add_child(attack_logic)
		attack_logic.enemy = self

func _physics_process(delta: float) -> void:
	if movement_logic and movement_logic.has_method("tick_movement"):
		movement_logic.tick_movement(delta)
	if attack_logic and attack_logic.has_method("tick_attack"):
		attack_logic.tick_attack(delta)

func apply_damage(amount: float, is_crit: bool) -> void:
	var dmg = amount * (pd.get_stat("crit_damage") if is_crit else 1.0)
	_show_damage_number(dmg, is_crit)
	take_damage(dmg)

func _show_damage_number(amount: float, is_crit: bool) -> void:
	var dn := DamageNumber.new()
	damage_anchor.add_child(dn)
	dn.position = Vector2.ZERO
	dn.add_damage(amount, is_crit)

func on_death() -> void:
	if status_component and status_component.has_method("clear_all"):
		status_component.clear_all()
	emit_signal("died")
	queue_free()
