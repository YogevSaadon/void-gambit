# scripts/game/Level.gd
extends Node2D
class_name Level

"""
Main gameplay scene: initialises the player, drives the wave system,
and spawns enemies just outside the camera view (Vampire Survivors style).
Compatible with all Godot 4.x versions (no get_visible_rect needed).
"""

# ====== EDITOR‑TUNABLE SPAWN SETTINGS ======
@export_range(0.0, 500.0, 10.0)
var DISTANCE_VARIANCE : float = 100.0          # ± randomness for natural feel

@export_range(0.0, 256.0, 4.0)
var SPAWN_MARGIN      : float = 64.0           # Extra pixels beyond screen edge

@export var DEBUG_SPAWNS : bool = false        # Toggle verbose spawn logs

# ====== NODES ======
@onready var player        : Player      = $Player
@onready var level_ui      : LevelUI     = $LevelUI
@onready var wave_manager  : WaveManager = $WaveManager

# ====== AUTOLOAD SINGLETONS ======
@onready var game_manager  : GameManager          = get_node("/root/GameManager")
@onready var player_data   : PlayerData           = get_node("/root/PlayerData")
@onready var pem           : PassiveEffectManager = get_node("/root/PassiveEffectManager")

# ====== BUILT‑IN METHODS ======
func _ready() -> void:
	_initialise_player()
	_initialise_managers()
	_start_level()

func _exit_tree() -> void:
	# MEMORY LEAK FIX: remove stray damage numbers left in tree when scene changes
	for dn in get_tree().get_nodes_in_group("DamageNumbers"):
		if is_instance_valid(dn):
			dn.queue_free()

# ====== INITIALISATION ======
func _initialise_player() -> void:
	player.player_data = player_data
	player.initialize(player_data)

	_equip_player_weapons()

	level_ui.set_player(player)
	pem.register_player(player)
	pem.initialize_from_player_data(player_data)

func _initialise_managers() -> void:
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.enemy_spawned.connect(_on_enemy_spawned)
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.level_completed.connect(_on_level_completed)

func _equip_player_weapons() -> void:
	"""Load weapons from PlayerData, ensuring at least a basic default."""
	player.clear_all_weapons()

	var weapon_scenes : Array[PackedScene] = player_data.get_equipped_weapon_scenes()
	for i in range(weapon_scenes.size()):
		var scene := weapon_scenes[i]
		if scene:
			player.equip_weapon(scene, i)

	# Guarantee slot 0 holds *something*
	if weapon_scenes.is_empty() or not weapon_scenes[0]:
		player_data.ensure_default_weapon()
		_equip_player_weapons()   # one safe recursion pass

# ====== LEVEL FLOW ======
func _start_level() -> void:
	wave_manager.set_level(game_manager.level_number)
	wave_manager.start_level()

	if DEBUG_SPAWNS:
		var info = PowerBudgetCalculator.get_level_info(game_manager.level_number)

# ====== WAVE SIGNAL HANDLERS ======
func _on_wave_started(wave_number: int) -> void:
	player.reset_per_level()
	player.blink_system.initialize(player, player_data)

func _on_enemy_spawned(enemy: Node) -> void:
	enemy.global_position = _get_spawn_position_outside_camera()
	add_child(enemy)

func _on_wave_completed(_wave_number: int) -> void:
	pass  # placeholder for rewards / UI

func _on_level_completed(_level_number: int) -> void:
	player_data.sync_from_player(player)
	get_tree().change_scene_to_file("res://scenes/game/Hangar.tscn")

# ====== PLAYER‑RELATIVE SPAWN SYSTEM (CAMERA‑AWARE RING) ======
func _get_spawn_position_outside_camera() -> Vector2:
	"""
	Enemies spawn at a distance equal to the half‑diagonal of the camera’s
	visible rect plus SPAWN_MARGIN, with ± variance. Works on any resolution
	or zoom level without using get_visible_rect().
	"""
	if not is_instance_valid(player):
		push_warning("Level: Player missing – using fallback spawn.")
		return _get_fallback_spawn_position()

	var cam : Camera2D = get_viewport().get_camera_2d()
	if cam == null:
		push_warning("Level: No active Camera2D – using fallback spawn.")
		return _get_fallback_spawn_position()

	# 1) Viewport pixel size
	var vp_size : Vector2 = get_viewport_rect().size

	# 2) Convert to world units via camera zoom (assumes no rotation / uniform scale)
	var world_size : Vector2 = vp_size * cam.zoom

	# 3) Half‑diagonal = furthest visible distance from centre
	var half_diag : float = world_size.length() * 0.5

	# 4) Final spawn distance with margin & variance
	var distance : float = half_diag + SPAWN_MARGIN \
						   + randf_range(-DISTANCE_VARIANCE, DISTANCE_VARIANCE)

	# 5) Random angle (full 360° around player)
	var angle : float = randf() * TAU

	# 6) Compute position
	var dir : Vector2 = Vector2.RIGHT.rotated(angle)
	var pos : Vector2 = player.global_position + dir * distance

	if DEBUG_SPAWNS:
		print("Spawn @ %.0f px / %.0f° (half‑diag %.0f, zoom %s)"
			  % [distance, rad_to_deg(angle), half_diag, cam.zoom])

	return pos

func _get_fallback_spawn_position() -> Vector2:
	"""Used if player or camera reference is invalid (should be rare)."""
	var centre : Vector2 = get_viewport_rect().size * 0.5
	var angle  : float   = randf() * TAU
	return centre + Vector2.RIGHT.rotated(angle) * (512.0 + SPAWN_MARGIN)
