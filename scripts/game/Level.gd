extends Node2D
class_name Level

# ====== Exports ======
@export var enemy_scene: PackedScene

# ====== Nodes ======
var player: Player = null
@onready var level_ui     = $LevelUI
@onready var wave_manager = $WaveManager

@onready var game_manager = get_tree().root.get_node("GameManager") 
@onready var player_data  = get_tree().root.get_node("PlayerData") 
@onready var pem          = get_tree().root.get_node("PassiveEffectManager") 

# ====== Constants ======
const SCREEN_SIDES := 4

# ====== Built-in Methods ======
func _ready() -> void:
	player = $Player
	player.player_data = player_data
	player.initialize(player_data)

	pem.register_player(player)
	pem.initialize_from_player_data(player_data)

	_set_wave_enemy_scene()
	level_ui.set_player(player)
	_connect_wave_signals()
	_equip_player_weapons()
	_start_level()

# ====== Wave Setup ======
func _set_wave_enemy_scene() -> void:
	if enemy_scene == null:
		enemy_scene = preload("res://scenes/actors/enemys/triangle/Triangle.tscn")
	wave_manager.enemy_scene = enemy_scene

func _connect_wave_signals() -> void:
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.enemy_spawned.connect(_on_enemy_spawned)
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.level_completed.connect(_on_level_completed)

func _equip_player_weapons() -> void:
	player.clear_all_weapons()
	# Fixed iteration over the loadout array
	for i in range(game_manager.equipped_weapons.size()):
		var weapon_scene = game_manager.equipped_weapons[i]
		if weapon_scene:
			player.equip_weapon(weapon_scene, i)

func _start_level() -> void:
	wave_manager.set_level(game_manager.level_number)
	wave_manager.start_level()

# ====== Wave Signal Handlers ======
func _on_wave_started(wave_number: int) -> void:
	print("Wave %d started!" % wave_number)
	player.reset_per_level()
	player.blink_system.initialize(player, player_data)

func _on_enemy_spawned(enemy: Node) -> void:
	add_child(enemy)
	enemy.global_position = _get_random_spawn_position()

func _on_wave_completed(wave_number: int) -> void:
	print("Wave %d complete!" % wave_number)

func _on_level_completed(level_number: int) -> void:
	print("Level %d finished!" % level_number)
	
	player_data.sync_from_player(player)
	get_tree().change_scene_to_file("res://scenes/game/Hangar.tscn")

# ====== Utility ======
func _get_random_spawn_position() -> Vector2:
	var screen_size = get_viewport_rect().size
	match randi() % SCREEN_SIDES:
		0: return Vector2(randf_range(0.0, screen_size.x), 0.0)
		1: return Vector2(randf_range(0.0, screen_size.x), screen_size.y)
		2: return Vector2(0.0, randf_range(0.0, screen_size.y))
		3: return Vector2(screen_size.x, randf_range(0.0, screen_size.y))
	return Vector2.ZERO

# ====== MEMORY LEAK FIX ======
func _exit_tree() -> void:
	# Cleanup any remaining damage numbers
	var damage_numbers = get_tree().get_nodes_in_group("DamageNumbers")
	for dn in damage_numbers:
		if is_instance_valid(dn):
			dn.queue_free()
