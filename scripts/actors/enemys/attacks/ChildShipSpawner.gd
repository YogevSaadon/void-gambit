# scripts/actors/enemys/attacks/ChildShipSpawner.gd
extends BaseEntitySpawner
class_name ChildShipSpawner

@export var shooting_range: float = AttackConstants.CHILD_SHIP_SPAWNER_RANGE
@export var spawn_interval : float = AttackConstants.CHILD_SHIP_SPAWN_INTERVAL
@export var child_ship_scene: PackedScene = preload("res://scenes/actors/enemys/ChildShip.tscn")
@export var spawn_offset_distance: float = AttackConstants.CHILD_SHIP_SPAWN_OFFSET_DISTANCE

var _spawn_timer   : float = 0.0
var _range_timer  : float = 0.0
var _player_pos   : Vector2
var _player_in_range : bool = false

@onready var muzzle        : Node2D   = $Muzzle
@onready var weapon_sprite : Sprite2D = $WeaponSprite

const RANGE_CHECK_INTERVAL := AttackConstants.RANGE_CHECK_INTERVAL

func _ready() -> void:
	# Set MotherShip-specific entity limit
	max_entities_per_spawner = 8
	
	# Call parent _ready() to initialize base functionality
	super._ready()
	
	if not _owner_enemy:
		return

	_spawn_timer = randf_range(0.0, spawn_interval)
	_range_timer = randf_range(0.0, RANGE_CHECK_INTERVAL)

	if weapon_sprite:
		weapon_sprite.scale *= 1.0 + (_owner_enemy.power_level - 1.0) * 0.4

func _physics_process(delta: float) -> void:
	# Call parent for entity cleanup
	super._physics_process(delta)
	tick_attack(delta)

func tick_attack(delta: float) -> void:
	_spawn_timer -= delta
	_range_timer -= delta

	if _range_timer <= 0.0:
		_range_timer = RANGE_CHECK_INTERVAL
		_update_player_cache()

	if _player_in_range and _spawn_timer <= 0.0:
		_spawn_child_ship()
		_spawn_timer = spawn_interval

func _spawn_child_ship() -> void:
	if not muzzle or not child_ship_scene:
		push_error("ChildShipSpawner: Missing muzzle or child ship scene")
		return

	# Use the new entity spawning system
	var child_ship = try_spawn_entity()
	if child_ship:
		_flash()

# ===== OVERRIDE BASE CLASS METHODS =====
func _create_entity() -> Node:
	"""Create a new ChildShip entity"""
	if not child_ship_scene:
		push_error("ChildShipSpawner: No child_ship_scene configured")
		return null
	
	var child_ship = child_ship_scene.instantiate()
	get_tree().current_scene.add_child(child_ship)
	return child_ship

func _setup_entity(entity: Node) -> void:
	"""Configure the ChildShip after creation"""
	# Call parent setup first (applies power scaling)
	super._setup_entity(entity)
	
	# Position the ship around the muzzle
	if muzzle:
		var angle = randf() * TAU
		var spawn_position = muzzle.global_position + Vector2(cos(angle), sin(angle)) * spawn_offset_distance
		entity.global_position = spawn_position

func _find_parent_enemy() -> BaseEnemy:
	var p := get_parent()
	while p and not (p is BaseEnemy):
		p = p.get_parent()
	
	if not p:
		push_error("ChildShipSpawner: No BaseEnemy parent found")
	
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
