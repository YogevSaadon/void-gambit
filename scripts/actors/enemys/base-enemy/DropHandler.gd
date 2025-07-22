# scripts/actors/enemys/base-enemy/DropHandler.gd
extends Node
class_name DropHandler

@export var drop_scene: PackedScene = preload("res://scenes/drops/CreditDrop.tscn")
@export var drop_value_multiplier: float = 4.0

var enemy: BaseEnemy

func _ready() -> void:
	enemy = get_parent() as BaseEnemy

func drop_loot() -> void:
	if not drop_scene:
		return
		
	var drop = drop_scene.instantiate()
	drop.global_position = enemy.global_position
	drop.value = int(enemy.power_level * drop_value_multiplier)
	enemy.get_tree().current_scene.add_child(drop)
