extends Control

var gm: Node = null

func _ready():
	_bootstrap_game_manager()
	$MarginContainer/BoxContainer/StartGame.pressed.connect(_on_start_pressed)
	$MarginContainer/BoxContainer/Quit.pressed.connect(_on_quit_pressed)

func _bootstrap_game_manager():
	var root = get_tree().root
	if not root.has_node("GameManager"):
		gm = preload("res://scripts/game/GameManager.gd").new()
		gm.name = "GameManager"
		get_tree().root.call_deferred("add_child", gm)
	else:
		gm = root.get_node("GameManager")

func _on_start_pressed():
	gm.reset_run()
	get_tree().change_scene_to_file("res://scenes/game/Level.tscn")

func _on_quit_pressed():
	get_tree().quit()
