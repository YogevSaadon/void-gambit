extends Control

func _ready():
	_bootstrap_managers()
	$MarginContainer/BoxContainer/StartGame.pressed.connect(_on_start_pressed)
	$MarginContainer/BoxContainer/Quit.pressed.connect(_on_quit_pressed)

func _bootstrap_managers():
	var root = get_tree().root

	# Remove any old manager nodes
	for name in ["GameManager", "PassiveEffectManager", "PlayerData"]:
		if root.has_node(name):
			root.get_node(name).queue_free()

	await get_tree().process_frame  # Wait once for all to be cleared

	# Add fresh instances
	var gm = preload("res://scripts/game/managers/GameManager.gd").new()
	gm.name = "GameManager"
	root.call_deferred("add_child", gm)

	var pem = preload("res://scripts/game/managers/PassiveEffectManager.gd").new()
	pem.name = "PassiveEffectManager"
	root.call_deferred("add_child", pem)

	var pd = preload("res://scripts/actors/player/PlayerData.gd").new()
	pd.name = "PlayerData"
	root.call_deferred("add_child", pd)
	

	var db  = preload("res://scripts/game/ItemDatabase.gd").new()
	db.name = "ItemDatabase"
	root.add_child(db)
	await get_tree().process_frame          
	db.load_from_json()                     


func get_game_manager() -> GameManager:
	return get_tree().root.get_node("GameManager") as GameManager

func get_player_data() -> PlayerData:
	return get_tree().root.get_node("PlayerData") as PlayerData

func _on_start_pressed():
	get_game_manager().reset_run()
	get_player_data().reset()

	var pem := get_tree().root.get_node_or_null("PassiveEffectManager") as PassiveEffectManager
	if pem:
		pem.reset()

	get_tree().change_scene_to_file("res://scenes/game/Level.tscn")

func _on_quit_pressed():
	get_tree().quit()
