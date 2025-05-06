extends Node
class_name GameManager

@export var starting_weapon: PackedScene = preload("res://scenes/weapons/FiringWeapon.tscn")

# ====== Game State ======
var coins: int = 0
var gold_coins: int = 0
var level_number: int = 1

# ====== Weapon Loadout ======
var equipped_weapons: Array[PackedScene] = []

func _ready() -> void:
	_initialize_loadout()

func _initialize_loadout() -> void:
	equipped_weapons.clear()
	equipped_weapons.resize(6)
	equipped_weapons[0] = starting_weapon

func reset_run() -> void:
	coins = 0
	gold_coins = 0
	level_number = 1
	_initialize_loadout()

func next_level() -> void:
	level_number += 1

func add_coins(amount: int) -> void:
	coins += amount

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		return true
	return false
