extends Node
class_name WaveManager

@export var enemy_scene: PackedScene = preload("res://scenes/actors/Enemy.tscn")
@export var base_enemies_per_wave: int = 3
@export var spawn_interval: float = 0.5      # Seconds between individual spawns
@export var inter_wave_delay: float = 5.0    # Seconds between waves
@export var waves_per_level: int = 5         # Total number of waves in this level

signal wave_started(wave_number: int)
signal enemy_spawned(enemy: Node)
signal wave_completed(wave_number: int)
signal level_completed(level_number: int)

var _current_wave: int = 0

func start_level() -> void:
	_current_wave = 0
	_start_next_wave()

func _start_next_wave() -> void:
	_current_wave += 1
	emit_signal("wave_started", _current_wave)
	var count := base_enemies_per_wave * _current_wave
	_spawn_wave(count)

func _spawn_wave(count: int) -> void:
	for i in count:
		var enemy := enemy_scene.instantiate()
		add_child(enemy)
		emit_signal("enemy_spawned", enemy)
		await get_tree().create_timer(spawn_interval).timeout
	emit_signal("wave_completed", _current_wave)
	await get_tree().create_timer(inter_wave_delay).timeout
	if _current_wave < waves_per_level:
		_start_next_wave()
	else:
		emit_signal("level_completed", _current_wave)
