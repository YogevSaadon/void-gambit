extends Node2D
class_name Level

# ====== Exports ======
@export var enemy_scene: PackedScene  # Optional override if needed

# ====== Onready Variables ======
@onready var player = $Player
@onready var level_ui = $LevelUI
@onready var wave_manager = $WaveManager
@onready var gm = get_tree().root.get_node("GameManager")

# ====== Constants ======
const SCREEN_SIDES: int = 4  # Top, Bottom, Left, Right

# ====== Built-in Methods ======

func _ready() -> void:
	level_ui.set_player(player)
	_set_wave_enemy_scene()
	_connect_wave_signals()
	_equip_player_weapons()
	_start_level()
	
	var pem = get_tree().root.get_node("PassiveEffectManager")
	pem.register_signals(player)


# ====== Initialization Helpers ======

func _set_wave_enemy_scene() -> void:
	wave_manager.enemy_scene = preload("res://scenes/actors/Enemy.tscn")

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

func _start_level() -> void:
	wave_manager.set_level(gm.level_number)
	wave_manager.start_level()

# ====== Wave Signal Handlers ======

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
	get_tree().change_scene_to_file("res://scenes/game/Hangar.tscn")

# ====== Utility Methods ======

func _get_random_spawn_position() -> Vector2:
	var screen_size = get_viewport_rect().size
	var side = randi() % SCREEN_SIDES

	match side:
		0: return Vector2(randf_range(0.0, screen_size.x), 0.0)  # Top
		1: return Vector2(randf_range(0.0, screen_size.x), screen_size.y)  # Bottom
		2: return Vector2(0.0, randf_range(0.0, screen_size.y))  # Left
		3: return Vector2(screen_size.x, randf_range(0.0, screen_size.y))  # Right
	return Vector2.ZERO
