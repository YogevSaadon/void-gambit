extends Node2D
class_name Level

# Just declare the types here; assign them in _ready()
@export var enemy_scene: PackedScene
var player
var wave_manager

func _ready() -> void:
	# 1) Load the enemy scene
	enemy_scene = preload("res://scenes/actors/Enemy.tscn")

	# 2) Grab our child nodes
	player = $Player
	wave_manager = $WaveManager

	# 3) Equip player from GameManager
	var gm = get_tree().get_root().get_node("GameManager")
	player.clear_all_weapons()
	for i in range(gm.equipped_weapons.size()):
		var ws = gm.equipped_weapons[i]
		if ws:
			player.equip_weapon(ws, i)

	# 4) Wire up wave signals
	wave_manager.connect("wave_started",    Callable(self, "_on_wave_started"))
	wave_manager.connect("enemy_spawned",   Callable(self, "_on_enemy_spawned"))
	wave_manager.connect("wave_completed",  Callable(self, "_on_wave_completed"))
	wave_manager.connect("level_completed", Callable(self, "_on_level_completed"))

	# 5) Start the waves
	wave_manager.start_level()

func _on_wave_started(wave_number: int) -> void:
	print("Wave %d started" % wave_number)

func _on_enemy_spawned(enemy: Node) -> void:
	# Add the enemy under this scene and place it
	add_child(enemy)
	var x = randi() % 800
	var y := -50 if randi() % 2 == 0 else 650
	enemy.global_position = Vector2(x, y)

func _on_wave_completed(wave_number: int) -> void:
	print("Wave %d completed" % wave_number)
	var gm = get_tree().get_root().get_node("GameManager")
	gm.add_coins(wave_number * 5)

func _on_level_completed(level_number: int) -> void:
	print("Level %d completed!" % level_number)
	var gm = get_tree().get_root().get_node("GameManager")
	gm.advance_level()
	player.clear_all_weapons()
	get_tree().change_scene("res://scenes/Hangar.tscn")
