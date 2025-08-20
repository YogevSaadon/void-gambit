# scripts/game/managers/WaveManager.gd
extends Node
class_name WaveManager

# ───── Signals ─────
signal wave_started(wave_number: int)
signal enemy_spawned(enemy: Node)
signal wave_completed(wave_number: int)
signal level_completed(level_number: int)

# ───── Dependencies ─────
var simple_spawner: SimpleEnemySpawner
var golden_spawner: GoldenShipSpawner

# ───── Tunables ─────
@export var spawn_batch_interval: float = 1.0   # Time between spawn cycles
@export var enemy_spawn_interval: float  = 0.3   # Interval inside a batch
@export var level_duration: float        = 60.0  # Wave duration

# ───── References ─────
@onready var gm = get_tree().root.get_node("GameManager")
@onready var pd = get_tree().root.get_node("PlayerData")

# ───── Runtime state ─────
var current_level: int = 1

var _batch_timer:  float = 0.0
var _level_timer:  float = 0.0
var _golden_ship_timer: float = 0.0
var _enemy_spawn_queue: Array[PackedScene] = []
var _spawn_timer: float = 0.0
var _level_running: bool = false
var _batch_count: int = 0

# ───── Golden‑Ship tracking ─────
var _golden_ship_interval: float = 8.0
var _golden_ships_spawned: int = 0
var _golden_ships_required: int = 0

# ───── Setup ─────
func _ready() -> void:
	simple_spawner = SimpleEnemySpawner.new()
	golden_spawner = GoldenShipSpawner.new()

# ───── Level configuration ─────
func set_level(level: int) -> void:
	current_level = level
	level_duration = 10.0  # Fixed duration

# ───── Level start ─────
func start_level() -> void:
	# Core timers
	_level_timer  = level_duration
	_batch_timer  = 0.1                       # first batch almost instantly
	_batch_count  = 0
	_level_running = true
	_enemy_spawn_queue.clear()

	# ── Golden‑Ship scheduling (UNCHANGED) ───────────────────────────────────
	_golden_ships_required = int(pd.get_stat("golden_ship_count"))
	_golden_ships_spawned  = 0

	if _golden_ships_required > 0:
		_golden_ship_timer = 1.0

		if _golden_ships_required > 1:
			var remaining_time  = level_duration * 0.5 - _golden_ship_timer
			var remaining_ships = max(1, _golden_ships_required - 1)
			_golden_ship_interval = remaining_time / remaining_ships
		else:
			_golden_ship_interval = 999999.0
	else:
		_golden_ship_timer    = 999999.0
		_golden_ship_interval = 999999.0
	# ─────────────────────────────────────────────────────────────────────────

	emit_signal("wave_started", 1)

# ───── Main loop ─────
func _physics_process(delta: float) -> void:
	if not _level_running:
		return

	_level_timer  -= delta
	_batch_timer  -= delta
	_golden_ship_timer -= delta
	_spawn_timer  -= delta

	# ── Spawn normal batch ──
	if _batch_timer <= 0.0:
		_spawn_new_batch()
		_batch_timer = spawn_batch_interval

	# ── Spawn golden ship(s) (UNCHANGED) ──
	if _golden_ship_timer <= 0.0 and _golden_ships_spawned < _golden_ships_required:
		_spawn_golden_ship()
		_golden_ships_spawned += 1
		_golden_ship_timer = _golden_ship_interval

	# ── Spawn queued enemies ──
	_spawn_from_queue(delta)

	# ── Finish level ──
	if _level_timer <= 0.0:
		_finish_level()

# ───── NEW: Simple Batch Generation ─────
func _spawn_new_batch() -> void:
	_batch_count += 1
	var new_enemies = simple_spawner.generate_simple_spawn_list(current_level)
	for enemy_scene in new_enemies:
		_enemy_spawn_queue.append(enemy_scene)
	_enemy_spawn_queue.shuffle()

# ───── Golden‑Ship spawn (UNCHANGED) ─────
func _spawn_golden_ship() -> void:
	var golden_ships = golden_spawner.generate_golden_ships(current_level, pd)
	for golden_scene in golden_ships:
		var golden_ship = golden_scene.instantiate()
		golden_spawner.apply_tier_scaling_to_golden_ship(golden_ship, current_level)
		emit_signal("enemy_spawned", golden_ship)

# ───── Queue draining (UNCHANGED) ─────
func _spawn_from_queue(delta: float) -> void:
	if _enemy_spawn_queue.is_empty():
		return
	if _spawn_timer <= 0.0:
		_spawn_timer = enemy_spawn_interval
		var enemy_scene = _enemy_spawn_queue.pop_front()
		_spawn_enemy_from_scene(enemy_scene)

func _spawn_enemy_from_scene(enemy_scene: PackedScene) -> void:
	if enemy_scene == null:
		push_error("WaveManager: Null enemy scene!")
		return

	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.call_deferred("_post_spawn_setup", current_level)
	emit_signal("enemy_spawned", enemy)

# ───── Level end (UNCHANGED) ─────
func _finish_level() -> void:
	_level_running = false
	emit_signal("wave_completed", _batch_count)
	await get_tree().create_timer(2.0).timeout
	emit_signal("level_completed", current_level)

# ───── Public helpers (SIMPLIFIED) ─────
func get_level_progress() -> float:
	return 1.0 if level_duration <= 0 else 1.0 - (_level_timer / level_duration)

func get_time_remaining() -> float:
	return max(0.0, _level_timer)

func get_next_batch_time() -> float:
	return max(0.0, _batch_timer)

func get_next_golden_ship_time() -> float:
	return max(0.0, _golden_ship_timer)

func is_level_running() -> bool:
	return _level_running

func get_spawning_statistics() -> Dictionary:
	return {
		"level": current_level,
		"time_remaining": _level_timer,
		"level_progress": get_level_progress(),
		"batch_count": _batch_count,
		"next_batch_in": _batch_timer,
		"queue_size": _enemy_spawn_queue.size(),
		"golden_ships_spawned": _golden_ships_spawned,
		"golden_ships_required": _golden_ships_required,
		"next_golden_ship_in": _golden_ship_timer,
		"enemies_per_batch": simple_spawner.get_enemies_count_for_level(current_level),
		"tier": _get_tier_name(current_level),
		"tier_multiplier": _get_tier_multiplier(current_level)
	}

# ───── Simple tier system for colors ─────
func _get_tier_multiplier(level: int) -> int:
	if level < 6: return 1
	elif level < 12: return 2
	elif level < 18: return 3
	elif level < 24: return 4
	else: return 5

func _get_tier_name(level: int) -> String:
	if level < 6: return "White"
	elif level < 12: return "Green"
	elif level < 18: return "Blue"
	elif level < 24: return "Purple"
	else: return "Orange"
