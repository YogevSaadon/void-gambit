extends Node
class_name WaveManager

@export var enemy_scene: PackedScene
@export var waves: Array[Dictionary] = [
	{ "duration": 20.0, "enemy_count": 10, "spawn_interval": 2.0 },
	{ "duration": 30.0, "enemy_count": 15, "spawn_interval": 1.5 },
	{ "duration": 40.0, "enemy_count": 20, "spawn_interval": 1.0 },
]

signal wave_started(wave_number: int)
signal enemy_spawned(enemy: Node)
signal wave_completed(wave_number: int)
signal level_completed(level_number: int)

@onready var gm = get_tree().root.get_node("GameManager")

var _current_wave: int = -1
var _spawned_enemies: int = 0
var _spawn_timer: float = 0.0
var _wave_timer: float = 0.0
var _wave_running: bool = false
var _current_wave_data: Dictionary = {}

func start_level() -> void:
	_start_next_wave()

func _start_next_wave() -> void:
	_current_wave += 1
	if _current_wave >= waves.size():
		emit_signal("level_completed", gm.level_number)
		return

	_current_wave_data = waves[_current_wave]
	_wave_timer = _current_wave_data["duration"]
	_spawn_timer = 0.0
	_spawned_enemies = 0
	_wave_running = true

	emit_signal("wave_started", _current_wave + 1)

func _process(delta: float) -> void:
	if not _wave_running:
		return

	_wave_timer -= delta
	_spawn_timer -= delta

	if _spawned_enemies < _current_wave_data["enemy_count"] and _spawn_timer <= 0:
		_spawn_timer = _current_wave_data["spawn_interval"]
		var enemy = enemy_scene.instantiate()
		emit_signal("enemy_spawned", enemy)
		_spawned_enemies += 1

	if _wave_timer <= 0:
		_wave_running = false
		emit_signal("wave_completed", _current_wave + 1)
		await get_tree().create_timer(3.0).timeout
		_start_next_wave()
