extends Control

func _ready():
	# Bootstrap the GameManager once
	var root = get_tree().get_root()
	if not root.has_node("GameManager"):
		var gm = preload("res://scripts/game/GameManager.gd").new()
		gm.name = "GameManager"
		root.add_child(gm)

	# Connect UI buttons
	$MarginContainer/VBoxContainer/StartGame.connect("pressed", Callable(self, "_on_start_pressed"))
	$MarginContainer/VBoxContainer/Quit.connect("pressed", Callable(self, "_on_quit_pressed"))

func _on_start_pressed():
	var gm = get_tree().get_root().get_node("GameManager") as GameManager
	gm.reset_run()
	get_tree().change_scene("res://scenes/Level.tscn")

func _on_quit_pressed():
	get_tree().quit()
