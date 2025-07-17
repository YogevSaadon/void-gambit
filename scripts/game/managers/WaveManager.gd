# scripts/game/managers/WaveManager.gd
extends Node
class_name WaveManager

# ===== POWER BUDGET SYSTEM =====
var power_spawner: PowerBudgetSpawner
var golden_spawner: GoldenShipSpawner

# ===== SIGNALS =====
signal wave_started(wave_number: int)
signal enemy_spawned(enemy: Node)
signal wave_completed(wave_number: int)
signal level_completed(level_number: int)

# ===== CONTINUOUS SPAWNING CONFIGURATION =====
@export var spawn_batch_interval: float = 10.0   # Spawn new batch every 10 seconds
@export var enemy_spawn_interval: float = 0.3    # Individual enemies spawn every 0.3s within batch
@export var level_duration: float = 30.0         # Total level time (30 seconds for demo)
@export var golden_ship_interval: float = 8.0    # Golden ships every 8 seconds (fast!)

# ===== RUNTIME VARIABLES =====
@onready var gm = get_tree().root.get_node("GameManager")
@onready var pd = get_tree().root.get_node("PlayerData")

var current_level: int = 1
var power_budget_per_batch: int = 0

# ===== CONTINUOUS SPAWNING STATE =====
var _batch_timer: float = 0.0                    # Timer for next batch spawn
var _level_timer: float = 0.0                    # Total level time remaining
var _golden_ship_timer: float = 0.0              # Timer for Golden Ship spawns
var _enemy_spawn_queue: Array[PackedScene] = []  # Current batch of enemies to spawn
var _spawn_timer: float = 0.0                    # Timer for individual enemy spawning
var _level_running: bool = false
var _batch_count: int = 0                        # How many batches spawned

# ===== INITIALIZATION =====
func _ready() -> void:
	power_spawner = PowerBudgetSpawner.new()
	golden_spawner = GoldenShipSpawner.new()
	print("WaveManager: Continuous spawning system initialized")

# ===== PUBLIC METHODS =====
func set_level(level: int) -> void:
	current_level = level
	power_budget_per_batch = PowerBudgetCalculator.get_power_budget(level)
	level_duration = PowerBudgetCalculator.get_wave_duration(level)
	
	print("WaveManager: Level %d, %d power per batch, %.0fs total duration" % [
		level, power_budget_per_batch, level_duration
	])

func start_level() -> void:
	"""Start continuous spawning for this level"""
	_level_timer = level_duration
	_batch_timer = 0.1  # Spawn first batch almost immediately
	_golden_ship_timer = 3.0  # First Golden Ship after 3 seconds (quick!)
	_batch_count = 0
	_level_running = true
	_enemy_spawn_queue.clear()
	
	print("=== STARTING CONTINUOUS LEVEL %d ===" % current_level)
	print("Batch every %.1fs, Level duration %.0fs" % [spawn_batch_interval, level_duration])
	
	emit_signal("wave_started", 1)

# ===== CONTINUOUS SPAWNING LOGIC =====
func _physics_process(delta: float) -> void:
	if not _level_running:
		return
	
	# Update timers
	_level_timer -= delta
	_batch_timer -= delta
	_golden_ship_timer -= delta
	_spawn_timer -= delta
	
	# ===== SPAWN NEW ENEMY BATCH =====
	if _batch_timer <= 0.0:
		_spawn_new_batch()
		_batch_timer = spawn_batch_interval
	
	# ===== SPAWN GOLDEN SHIPS =====
	if _golden_ship_timer <= 0.0:
		_spawn_golden_ship()
		_golden_ship_timer = golden_ship_interval
	
	# ===== SPAWN INDIVIDUALS FROM CURRENT BATCH =====
	_spawn_from_queue(delta)
	
	# ===== CHECK LEVEL COMPLETION =====
	if _level_timer <= 0.0:
		_finish_level()

func _spawn_new_batch() -> void:
	"""Generate and queue a new batch of enemies"""
	_batch_count += 1
	
	print("=== SPAWNING BATCH %d (Level %d) ===" % [_batch_count, current_level])
	
	# Generate enemies for this batch using full power budget
	var new_enemies = power_spawner.generate_spawn_list(current_level)
	
	# Add to spawn queue
	for enemy_scene in new_enemies:
		_enemy_spawn_queue.append(enemy_scene)
	
	print("Batch %d: Added %d enemies to queue (queue size: %d)" % [
		_batch_count, new_enemies.size(), _enemy_spawn_queue.size()
	])
	
	# Shuffle for variety
	_enemy_spawn_queue.shuffle()

func _spawn_golden_ship() -> void:
	"""Spawn a Golden Ship"""
	var golden_ships = golden_spawner.generate_golden_ships(current_level, pd)
	
	for golden_scene in golden_ships:
		var golden_ship = golden_scene.instantiate()
		golden_spawner.apply_tier_scaling_to_golden_ship(golden_ship, current_level)
		emit_signal("enemy_spawned", golden_ship)
		print("Spawned Golden Ship (power: %d)" % golden_ship.power_level)

func _spawn_from_queue(delta: float) -> void:
	"""Spawn individual enemies from the queue at regular intervals"""
	if _enemy_spawn_queue.is_empty():
		return
	
	if _spawn_timer <= 0.0:
		_spawn_timer = enemy_spawn_interval
		
		var enemy_scene = _enemy_spawn_queue.pop_front()
		_spawn_enemy_from_scene(enemy_scene)

func _spawn_enemy_from_scene(enemy_scene: PackedScene) -> void:
	"""Spawn and configure an enemy"""
	if not enemy_scene:
		push_error("WaveManager: Null enemy scene!")
		return

	var enemy = enemy_scene.instantiate()
	
	# Apply tier scaling
	_apply_tier_scaling_to_enemy(enemy, current_level)
	
	emit_signal("enemy_spawned", enemy)
	
	var enemy_name = enemy_scene.resource_path.get_file().get_basename()
	print("Spawned: %s (power: %d)" % [enemy_name, enemy.power_level])

func _apply_tier_scaling_to_enemy(enemy: Node, level: int) -> void:
	"""Apply tier scaling to a regular enemy"""
	if not enemy:
		return
	
	var tier_multiplier = PowerBudgetCalculator.get_tier_multiplier(level)
	
	# Try new method first
	if enemy.has_method("apply_tier_scaling"):
		enemy.apply_tier_scaling(level)
	else:
		# Fallback: manual scaling for existing enemies
		var base_power = 1
		
		# Try to get base power from enemy
		if "base_power_level" in enemy:
			base_power = enemy.base_power_level
		elif "power_level" in enemy:
			base_power = enemy.power_level
		
		enemy.power_level = base_power * tier_multiplier
		
		# Apply scaling if method exists
		if enemy.has_method("_apply_power_scale"):
			enemy._apply_power_scale()

# ===== LEVEL COMPLETION =====
func _finish_level() -> void:
	"""Finish the level after time runs out"""
	_level_running = false
	
	print("=== LEVEL %d COMPLETED ===" % current_level)
	print("Total batches spawned: %d" % _batch_count)
	print("Enemies remaining in queue: %d" % _enemy_spawn_queue.size())
	
	emit_signal("wave_completed", _batch_count)
	
	# Short delay then complete level
	await get_tree().create_timer(2.0).timeout
	emit_signal("level_completed", current_level)

# ===== UTILITY METHODS =====
func get_level_progress() -> float:
	"""Get level completion progress (0.0 to 1.0)"""
	if level_duration <= 0:
		return 1.0
	return 1.0 - (_level_timer / level_duration)

func get_time_remaining() -> float:
	"""Get time remaining in level"""
	return max(0.0, _level_timer)

func get_next_batch_time() -> float:
	"""Get time until next batch spawns"""
	return max(0.0, _batch_timer)

func get_next_golden_ship_time() -> float:
	"""Get time until next Golden Ship spawns"""
	return max(0.0, _golden_ship_timer)

func is_level_running() -> bool:
	"""Check if level is currently running"""
	return _level_running

# ===== DEBUG METHODS =====
func print_spawning_status() -> void:
	"""Print current spawning status"""
	print("=== SPAWNING STATUS ===")
	print("Level: %d (%.1fs remaining)" % [current_level, _level_timer])
	print("Batch: %d (next in %.1fs)" % [_batch_count, _batch_timer])
	print("Queue: %d enemies waiting" % _enemy_spawn_queue.size())
	print("Golden Ship: next in %.1fs" % _golden_ship_timer)
	print("Power per batch: %d" % power_budget_per_batch)
	print("======================")

func get_spawning_statistics() -> Dictionary:
	"""Get detailed statistics"""
	return {
		"level": current_level,
		"time_remaining": _level_timer,
		"level_progress": get_level_progress(),
		"batch_count": _batch_count,
		"next_batch_in": _batch_timer,
		"queue_size": _enemy_spawn_queue.size(),
		"next_golden_ship_in": _golden_ship_timer,
		"power_per_batch": power_budget_per_batch,
		"tier": PowerBudgetCalculator.get_tier_name(current_level),
		"tier_multiplier": PowerBudgetCalculator.get_tier_multiplier(current_level)
	}

# ===== CONFIGURATION METHODS =====
func set_spawn_intervals(batch_interval: float, enemy_interval: float) -> void:
	"""Configure spawn timing"""
	spawn_batch_interval = max(1.0, batch_interval)
	enemy_spawn_interval = max(0.1, enemy_interval)
	print("Updated intervals: %.1fs batch, %.1fs enemies" % [spawn_batch_interval, enemy_spawn_interval])

func set_golden_ship_interval(interval: float) -> void:
	"""Configure Golden Ship spawn timing"""
	golden_ship_interval = max(5.0, interval)
	print("Updated Golden Ship interval: %.1fs" % golden_ship_interval)
