# File: res://scripts/GameManager.gd

extends Node
class_name GameManager

# Global game state persisted across scenes
var coins: int = 0
var equipped_weapons: Array = []
var level_number: int = 1

func _ready():
	# Initialize weapon slots (6 slots total) and give a default weapon
	equipped_weapons.resize(6)
	equipped_weapons[0] = preload("res://scenes/weapons/FiringWeapon.tscn")

func reset_run():
	# Reset state for a new game run
	coins = 0
	level_number = 1
	equipped_weapons.clear()
	equipped_weapons.resize(6)
	equipped_weapons[0] = preload("res://scenes/weapons/FiringWeapon.tscn")

func next_level():
	level_number += 1

func add_coins(amount: int) -> void:
	coins += amount

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		return true
	return false
