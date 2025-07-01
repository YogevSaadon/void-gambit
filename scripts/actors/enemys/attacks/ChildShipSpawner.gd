# scripts/actors/enemys/attacks/ChildShipSpawner.gd
extends Node2D
class_name ChildShipSpawner

# ───── TUNABLES ──────────────────────────────────────────────
@export var shooting_range: float       = 1040.0    # 30% more range (was 800)
@export var spawn_interval : float       = 6.0      # Spawns child ships instead of bullets
@export var child_ship_scene: PackedScene = preload(
	"res://scenes/actors/enemys/child/ChildShip.tscn"
)
@export var spawn_offset_distance: float = 50.0     # How far from Mother to spawn children

# ───── RUNTIME STATE ─────────────────────────────────────────
var _owner_enemy  : BaseEnemy
var _spawn_timer   : float = 0.0
var _range_timer  : float = 0.0
var _player_pos   : Vector2
var _player_in_range : bool = false

# ───── CHILD REFERENCES ─────────────────────────────────────
@onready var muzzle        : Node2D   = $Muzzle
@onready var weapon_sprite : Sprite2D = $WeaponSprite

const RANGE_CHECK_INTERVAL := 0.2

func _ready() -> void:
	_owner_enemy = _find_parent_enemy()
	assert(_owner_enemy, "ChildShipSpawner must be inside a BaseEnemy scene")

	# Randomise timers so Mother Ships don't spawn in sync
	_spawn_timer = randf_range(0.0, spawn_interval)
	_range_timer = randf_range(0.0, RANGE_CHECK_INTERVAL)

	# Make spawner bigger for stronger Mother Ships
	if weapon_sprite:
		weapon_sprite.scale *= 1.0 + (_owner_enemy.power_level - 1.0) * 0.4

func _physics_process(delta: float) -> void:
	tick_attack(delta)

func tick_attack(delta: float) -> void:
	_spawn_timer -= delta
	_range_timer -= delta

	# Periodically refresh distance cache
	if _range_timer <= 0.0:
		_range_timer = RANGE_CHECK_INTERVAL
		_update_player_cache()

	# Spawn child ship when ready
	if _player_in_range and _spawn_timer <= 0.0:
		_spawn_child_ship()
		_spawn_timer = spawn_interval

func _spawn_child_ship() -> void:
	if not muzzle or not child_ship_scene:
		push_error("ChildShipSpawner: Missing muzzle or child ship scene")
		return

	# Create child ship near the Mother Ship
	var child_ship = child_ship_scene.instantiate()
	
	# Spawn at random position around Mother Ship
	var angle = randf() * TAU
	var spawn_position = muzzle.global_position + Vector2(cos(angle), sin(angle)) * spawn_offset_distance
	child_ship.global_position = spawn_position
	
	# Pass power level from Mother Ship to child
	child_ship.power_level = _owner_enemy.power_level
	
	# Add child ship to scene
	get_tree().current_scene.add_child(child_ship)
	
	# Apply power scaling after adding to scene
	child_ship._apply_power_scale()
	
	print("Mother Ship spawned child ship with power level %d" % child_ship.power_level)
	_flash()

func _find_parent_enemy() -> BaseEnemy:
	var p := get_parent()
	while p and not (p is BaseEnemy):
		p = p.get_parent()
	return p as BaseEnemy

func _update_player_cache() -> void:
	var player := EnemyUtils.get_player()
	if not player:
		_player_in_range = false
		return

	_player_pos = player.global_position
	_player_in_range = _owner_enemy.global_position.distance_to(_player_pos) <= shooting_range

func _flash() -> void:
	if not weapon_sprite:
		return
	var tween := create_tween()
	tween.tween_property(weapon_sprite, "modulate", Color.WHITE, 0.15)
	tween.tween_property(weapon_sprite, "modulate", weapon_sprite.modulate, 0.3)
