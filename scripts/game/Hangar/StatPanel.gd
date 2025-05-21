extends Node
class_name StatPanel

@onready var health_label = $HealthLabel
@onready var shield_label = $ShieldLabel
@onready var blinks_label = $BlinksLabel

var pd: PlayerData = null

func initialize(player_data: PlayerData) -> void:
	pd = player_data
	update_stats()

func update_stats() -> void:
	if pd == null:
		return

	health_label.text = "HP: %d" % pd.get_stat("max_hp")
	shield_label.text = "Shield: %d" % pd.get_stat("max_shield")
	blinks_label.text = "Blinks: %d" % int(pd.get_stat("blinks"))
