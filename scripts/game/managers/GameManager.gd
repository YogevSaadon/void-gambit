extends Node
class_name GameManager

# ====== Currency & Progress ======
var credits: int = 0       # Standard currency (from drops)
var coins: int = 0         # Premium/gold currency
var level_number: int = 1  # Current run level

# ====== Lifecycle ======
func _ready() -> void:
	# Weapon management now handled by PlayerData
	pass

func reset_run() -> void:
	credits = 0
	coins = 0
	level_number = 2
	# Weapon reset now handled by PlayerData.reset()

func next_level() -> void:
	level_number += 1

# ====== Credit Methods ======
func add_credits(amount: int) -> void:
	credits += amount

func spend_credits(amount: int) -> bool:
	if credits >= amount:
		credits -= amount
		return true
	return false

# ====== Coin Methods ======
func add_coins(amount: int) -> void:
	coins += amount

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		return true
	return false
