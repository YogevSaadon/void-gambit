# scripts/actors/enemys/attacks/MissileLauncherAttack.gd
extends BaseEntitySpawner
class_name MissileLauncherAttack

@export var shooting_range: float = AttackConstants.MISSILE_LAUNCHER_RANGE
@export var fire_interval : float = AttackConstants.MISSILE_LAUNCHER_INTERVAL
@export var missile_scene  : PackedScene = preload("res://scenes/actors/enemys/EnemyMissle.tscn")

var _fire_timer   : float = 0.0
var _range_timer  : float = 0.0
var _player_pos   : Vector2
var _player_in_range : bool = false

@onready var muzzle        : Node2D   = $Muzzle
@onready var weapon_sprite : Sprite2D = $WeaponSprite

const RANGE_CHECK_INTERVAL := AttackConstants.RANGE_CHECK_INTERVAL

func _ready() -> void:
	# Set Diamond-specific entity limit (fewer missiles than MotherShip ships)
	max_entities_per_spawner = 4
	
	# Call parent _ready() to initialize base functionality
	super._ready()
	
	if not _owner_enemy:
		return

	_fire_timer  = randf_range(0.0, fire_interval)
	_range_timer = randf_range(0.0, RANGE_CHECK_INTERVAL)

	if weapon_sprite:
		weapon_sprite.scale *= 1.0 + (_owner_enemy.power_level - 1.0) * 0.3

func _physics_process(delta: float) -> void:
	# Call parent for entity cleanup
	super._physics_process(delta)
	tick_attack(delta)

func tick_attack(delta: float) -> void:
	_fire_timer  -= delta
	_range_timer -= delta

	if _range_timer <= 0.0:
		_range_timer = RANGE_CHECK_INTERVAL
		_update_player_cache()

	if _player_in_range and _fire_timer <= 0.0:
		_launch_missile()
		_fire_timer = fire_interval

func _launch_missile() -> void:
	if not muzzle or not missile_scene:
		push_error("MissileLauncherAttack: Missing muzzle or missile scene")
		return

	# Use the new entity spawning system
	var missile = try_spawn_entity()
	if missile:
		_flash()

# ===== OVERRIDE BASE CLASS METHODS =====
func _create_entity() -> Node:
	"""Create a new EnemyMissile entity"""
	if not missile_scene:
		push_error("MissileLauncherAttack: No missile_scene configured")
		return null
	
	var missile = missile_scene.instantiate()
	get_tree().current_scene.add_child(missile)
	return missile

func _setup_entity(entity: Node) -> void:
	"""Configure the EnemyMissile after creation"""
	# Call parent setup first (applies power scaling)
	super._setup_entity(entity)
	
	# Position the missile at the muzzle
	if muzzle:
		entity.global_position = muzzle.global_position

func _find_parent_enemy() -> BaseEnemy:
	var p := get_parent()
	while p and not (p is BaseEnemy):
		p = p.get_parent()
	
	if not p:
		push_error("MissileLauncherAttack: No BaseEnemy parent found")
	
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
	tween.tween_property(weapon_sprite, "modulate", Color.WHITE, 0.1)
	tween.tween_property(weapon_sprite, "modulate", weapon_sprite.modulate, 0.2)
