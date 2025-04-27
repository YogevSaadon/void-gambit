extends Node
class_name GameManager

@export var starting_weapon: PackedScene = preload("res://scenes/weapons/FiringWeapon.tscn")

# ====== Core Game State ======
var coins: int = 0
var gold_coins: int = 0  # You use this in Hangar for Slot Machine
var level_number: int = 1

# ====== Player State ======
var equipped_weapons: Array[PackedScene] = []

# New system: Player stats dictionary
var player_stats: Dictionary = {
	"max_hp": 10000,
	"hp": 10000,
	"max_shield": 50,
	"shield": 50,
	"blinks": 3,
	"rerolls": 1,
}

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
	_reset_player_stats()

func _reset_player_stats() -> void:
	player_stats["hp"] = player_stats["max_hp"]
	player_stats["shield"] = player_stats["max_shield"]
	player_stats["blinks"] = 3
	player_stats["rerolls"] = 1

func next_level() -> void:
	level_number += 1

func add_coins(amount: int) -> void:
	coins += amount

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		return true
	return false
