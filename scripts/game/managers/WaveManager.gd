# scripts/game/managers/WaveManager.gd
extends Node
class_name WaveManager

# ───── Signals ─────
signal wave_started(wave_number: int)
signal enemy_spawned(enemy: Node)
signal wave_completed(wave_number: int)
signal level_completed(level_number: int)

# ───── Dependencies ─────
var power_spawner: PowerBudgetSpawner
var golden_spawner: GoldenShipSpawner

# ───── Tunables ─────
@export var spawn_batch_interval: float = 10.0   # Time between normal spawn batches
@export var enemy_spawn_interval: float  = 0.3   # Interval inside a batch
@export var level_duration: float        = 30.0  # Default – overwritten per‑level

# ───── References ─────
@onready var gm = get_tree().root.get_node("GameManager")
@onready var pd = get_tree().root.get_node("PlayerData")

# ───── Runtime state ─────
var current_level: int = 1
var power_budget_per_batch: int = 0

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
	power_spawner  = PowerBudgetSpawner.new()
	golden_spawner = GoldenShipSpawner.new()

# ───── Level configuration ─────
func set_level(level: int) -> void:
	current_level          = level
	power_budget_per_batch = PowerBudgetCalculator.get_power_budget(level)
	level_duration         = PowerBudgetCalculator.get_wave_duration(level)

# ───── Level start ─────
func start_level() -> void:
	# Core timers
	_level_timer  = level_duration
	_batch_timer  = 0.1                       # first batch almost instantly
	_batch_count  = 0
	_level_running = true
	_enemy_spawn_queue.clear()

	# ── Golden‑Ship scheduling ───────────────────────────────────────────────
	_golden_ships_required = int(pd.get_stat("golden_ship_count"))
	_golden_ships_spawned  = 0

	if _golden_ships_required > 0:
		# FIXED: First Gold‑Ship appears at second 1 to guarantee visibility
		_golden_ship_timer = 1.0

		# Remaining ships evenly until halfway point
		if _golden_ships_required > 1:
			var remaining_time  = level_duration * 0.5 - _golden_ship_timer
			var remaining_ships = max(1, _golden_ships_required - 1)
			_golden_ship_interval = remaining_time / remaining_ships
		else:
			_golden_ship_interval = 999999.0   # Only one ship this level
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

	# ── Spawn golden ship(s) ──
	if _golden_ship_timer <= 0.0 and _golden_ships_spawned < _golden_ships_required:
		_spawn_golden_ship()
		_golden_ships_spawned += 1
		_golden_ship_timer = _golden_ship_interval

	# ── Spawn queued enemies ──
	_spawn_from_queue(delta)

	# ── Finish level ──
	if _level_timer <= 0.0:
		_finish_level()

# ───── Batch generation ─────
func _spawn_new_batch() -> void:
	_batch_count += 1
	var new_enemies = power_spawner.generate_spawn_list(current_level)
	for enemy_scene in new_enemies:
		_enemy_spawn_queue.append(enemy_scene)
	_enemy_spawn_queue.shuffle()

# ───── Golden‑Ship spawn ─────
func _spawn_golden_ship() -> void:
	var golden_ships = golden_spawner.generate_golden_ships(current_level, pd)
	for golden_scene in golden_ships:
		var golden_ship = golden_scene.instantiate()
		golden_spawner.apply_tier_scaling_to_golden_ship(golden_ship, current_level)
		emit_signal("enemy_spawned", golden_ship)

# ───── Queue draining ─────
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

	# Add to scene immediately so its _ready() fires
	get_tree().current_scene.add_child(enemy)

	# Defer tier scaling to avoid zero‑stat issue (handled in BaseEnemy)
	enemy.call_deferred("_post_spawn_setup", current_level)

	emit_signal("enemy_spawned", enemy)

# ───── Level end ─────
func _finish_level() -> void:
	_level_running = false
	emit_signal("wave_completed", _batch_count)
	await get_tree().create_timer(2.0).timeout
	emit_signal("level_completed", current_level)

# ───── Public helpers ─────
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
		"power_per_batch": power_budget_per_batch,
		"tier": PowerBudgetCalculator.get_tier_name(current_level),
		"tier_multiplier": PowerBudgetCalculator.get_tier_multiplier(current_level)
	}
