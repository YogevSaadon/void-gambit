extends Node2D
class_name Level

@export var enemy_scene: PackedScene

@onready var player = $Player
@onready var level_ui = $LevelUI
@onready var wave_manager = $WaveManager
@onready var gm = get_tree().root.get_node("GameManager")

func _ready():
	level_ui.set_player(player)
	wave_manager.enemy_scene = preload("res://scenes/actors/Enemy.tscn")
	_connect_wave_signals()
	_equip_player_weapons()
	wave_manager.set_level(gm.level_number)
	wave_manager.start_level()

func _connect_wave_signals() -> void:
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.enemy_spawned.connect(_on_enemy_spawned)
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.level_completed.connect(_on_level_completed)

func _equip_player_weapons() -> void:
	player.clear_all_weapons()
	for i in gm.equipped_weapons.size():
		var weapon_scene = gm.equipped_weapons[i]
		if weapon_scene:
			player.equip_weapon(weapon_scene, i)

func _on_wave_started(wave_number: int) -> void:
	print("Wave %d started!" % wave_number)

func _on_enemy_spawned(enemy: Node) -> void:
	add_child(enemy)
	enemy.global_position = _get_random_spawn_position()

func _on_wave_completed(wave_number: int) -> void:
	print("Wave %d complete!" % wave_number)
	gm.add_coins(wave_number * 10)

func _on_level_completed(level_number: int) -> void:
	print("Level %d finished!" % level_number)
	get_tree().change_scene_to_file("res://scenes/game/Hanger.tscn")

func _get_random_spawn_position() -> Vector2:
	var screen_size = get_viewport_rect().size
	var side = randi() % 4
	match side:
		0: return Vector2(randf_range(0, screen_size.x), 0)
		1: return Vector2(randf_range(0, screen_size.x), screen_size.y)
		2: return Vector2(0, randf_range(0, screen_size.y))
		3: return Vector2(screen_size.x, randf_range(0, screen_size.y))
	return Vector2.ZERO
