extends Node


@onready var next_button = $NextLevelButton
@onready var gm = get_tree().root.get_node("GameManager")

func _ready() -> void:
	next_button.connect("pressed", Callable(self, "_on_next_level_pressed"))


func _on_next_level_pressed():
	gm.next_level()
	get_tree().change_scene_to_file("res://scenes/game/Level.tscn")

func _process(delta: float) -> void:
	pass
