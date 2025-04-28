extends Control

var gm: Node = null

func _ready():
	_bootstrap_managers()
	$MarginContainer/BoxContainer/StartGame.pressed.connect(_on_start_pressed)
	$MarginContainer/BoxContainer/Quit.pressed.connect(_on_quit_pressed)

func _bootstrap_managers():
	var root = get_tree().root
	
	if not root.has_node("GameManager"):
		gm = preload("res://scripts/game/GameManager.gd").new()
		gm.name = "GameManager"
		root.call_deferred("add_child", gm)
	
	if not root.has_node("PassiveEffectManager"):
		var pem = preload("res://scripts/game/PassiveEffectManager.gd").new()
		pem.name = "PassiveEffectManager"
		root.call_deferred("add_child", pem)


func _on_start_pressed():
	gm.reset_run()
	get_tree().change_scene_to_file("res://scenes/game/Level.tscn")

func _on_quit_pressed():
	get_tree().quit()
