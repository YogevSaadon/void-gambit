# scripts/game/Level.gd
extends Node2D
class_name Level

# ====== Exports (REMOVED - No longer needed) ======
# @export var enemy_scene: PackedScene                          # ← REMOVED
# @export var secondary_enemy_scene: PackedScene                # ← REMOVED

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

	# ===== REMOVED: No longer need to set enemy scenes =====
	# _set_wave_enemy_scene()  # ← REMOVED

	level_ui.set_player(player)
	_connect_wave_signals()
	_equip_player_weapons()
	_start_level()

# ===== REMOVED: Enemy scene setup no longer needed =====
# func _set_wave_enemy_scene() -> void:
# 	# This entire function is removed - WaveManager now handles enemy selection

func _connect_wave_signals() -> void:
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.enemy_spawned.connect(_on_enemy_spawned)
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.level_completed.connect(_on_level_completed)

func _equip_player_weapons() -> void:
	"""Load weapons from PlayerData with proper null handling"""
	player.clear_all_weapons()
	
	var weapon_scenes = player_data.get_equipped_weapon_scenes()
	print("Loading %d weapon slots from PlayerData" % weapon_scenes.size())
	
	for i in range(weapon_scenes.size()):
		var weapon_scene = weapon_scenes[i]
		if weapon_scene != null:
			player.equip_weapon(weapon_scene, i)
			print("Equipped weapon in slot %d: %s" % [i, weapon_scene.resource_path])
		else:
			print("No weapon equipped in slot %d" % i)
	
	# Verify default weapon is equipped
	var equipped_weapons = player_data.equipped_weapons
	if equipped_weapons.is_empty() or equipped_weapons[0] == "":
		push_warning("Level: No default weapon found, setting basic_bullet_weapon")
		player_data.equipped_weapons.resize(player_data.MAX_WEAPON_SLOTS)
		player_data.equipped_weapons[0] = "basic_bullet_weapon"
		_equip_player_weapons()  # Retry

func _start_level() -> void:
	wave_manager.set_level(game_manager.level_number)
	wave_manager.start_level()
	
	# ===== NEW: Print level info for debugging =====
	print("=== STARTING LEVEL %d ===" % game_manager.level_number)
	var level_info = PowerBudgetCalculator.get_level_info(game_manager.level_number)
	print("Power Budget: %d" % level_info.power_budget)
	print("Tier: %s (%dx multiplier)" % [level_info.tier_name, level_info.tier_multiplier])
	print("Wave Duration: %.0fs" % level_info.wave_duration)
	print("========================")

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
	for dn in get_tree().get_nodes_in_group("DamageNumbers"):
		if is_instance_valid(dn):
			dn.queue_free()
