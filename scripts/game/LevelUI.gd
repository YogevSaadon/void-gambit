extends CanvasLayer
class_name LevelUI

@onready var hp_bar = $Bars/HPBarContainer/HPBar
@onready var hp_text = $Bars/HPBarContainer/HPText
@onready var shield_bar = $Bars/ShieldBarContainer/ShieldBar
@onready var shield_text = $Bars/ShieldBarContainer/ShieldText

@onready var level_label = $LevelLabel
@onready var gm = get_tree().root.get_node("GameManager")

var player: Node = null


func _ready():
	level_label.text = "LEVEL %d" % gm.level_number

func set_player(p: Node) -> void:
	player = p

func _process(delta: float) -> void:
	if player == null:
		return


	hp_bar.max_value = player.max_health
	hp_bar.value = player.health
	hp_text.text = "%d/%d" % [player.health, player.max_health]

	shield_bar.max_value = player.max_shield
	shield_bar.value = player.shield
	shield_text.text = "%d/%d" % [player.shield, player.max_shield]
