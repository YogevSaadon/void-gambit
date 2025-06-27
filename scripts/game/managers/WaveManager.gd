extends Node
class_name WaveManager

# ====== Exports ======
@export var enemy_scene: PackedScene
@export var waves: Array[Dictionary] = [
	{ "duration": 60.0, "enemy_count": 10, "spawn_interval": 0.6 },
]

# ====== Signals ======
signal wave_started(wave_number: int)
signal enemy_spawned(enemy: Node)
signal wave_completed(wave_number: int)
signal level_completed(level_number: int)

# ====== Constants ======
const SPAWN_SCALING_PER_LEVEL: int = 2  # Extra enemies per level scaling

# ====== Runtime Variables ======
@onready var gm = get_tree().root.get_node("GameManager")

var current_level: int = 1
var _current_wave_index: int = -1
var _current_wave_data: Dictionary = {}
var _spawned_enemies: int = 0
var _spawn_timer: float = 0.0
var _wave_timer: float = 0.0
var _wave_running: bool = false

# ====== Public Methods ======

func set_level(level: int) -> void:
	current_level = level

func start_level() -> void:
	_start_next_wave()

# ====== Internal Methods ======

func _start_next_wave() -> void:
	_current_wave_index += 1
	
	if _current_wave_index >= waves.size():
		emit_signal("level_completed", gm.level_number)
		return
	
	_current_wave_data = waves[_current_wave_index].duplicate()

	# Scale enemy count by current level
	_current_wave_data["enemy_count"] += (current_level - 1) * SPAWN_SCALING_PER_LEVEL

	_wave_timer = _current_wave_data["duration"]
	_spawn_timer = 0.0
	_spawned_enemies = 0
	_wave_running = true

	emit_signal("wave_started", _current_wave_index + 1)

func _physics_process(delta: float) -> void:
	if not _wave_running:
		return
	
	_wave_timer -= delta
	_spawn_timer -= delta
	
	_handle_enemy_spawning()
	
	if _wave_timer <= 0.0:
		_finish_wave()

func _handle_enemy_spawning() -> void:
	if _spawned_enemies >= _current_wave_data["enemy_count"]:
		return

	if _spawn_timer <= 0.0:
		_spawn_timer = _current_wave_data["spawn_interval"]

		if enemy_scene == null:
			push_error("WaveManager: enemy_scene is null! Cannot instantiate.")
			return

		var enemy = enemy_scene.instantiate()
		emit_signal("enemy_spawned", enemy)
		_spawned_enemies += 1

func _finish_wave() -> void:
	_wave_running = false
	emit_signal("wave_completed", _current_wave_index + 1)
	await get_tree().create_timer(1.0).timeout
	_start_next_wave()
