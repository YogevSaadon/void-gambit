# scripts/actors/enemys/attacks/MissileLauncherAttack.gd
extends Node2D
class_name MissileLauncherAttack

@export var shooting_range: float = 1000.0
@export var fire_interval : float = 5.0
@export var missile_scene  : PackedScene = preload("res://scenes/actors/enemys/EnemyMissle.tscn")

var _owner_enemy  : BaseEnemy
var _fire_timer   : float = 0.0
var _range_timer  : float = 0.0
var _player_pos   : Vector2
var _player_in_range : bool = false

@onready var muzzle        : Node2D   = $Muzzle
@onready var weapon_sprite : Sprite2D = $WeaponSprite

const RANGE_CHECK_INTERVAL := 0.2

func _ready() -> void:
	_owner_enemy = _find_parent_enemy()
	if not _owner_enemy:
		return

	_fire_timer  = randf_range(0.0, fire_interval)
	_range_timer = randf_range(0.0, RANGE_CHECK_INTERVAL)

	if weapon_sprite:
		weapon_sprite.scale *= 1.0 + (_owner_enemy.power_level - 1.0) * 0.3

func _physics_process(delta: float) -> void:
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

	var missile = missile_scene.instantiate()
	missile.global_position = muzzle.global_position
	missile.power_level = _owner_enemy.power_level
	
	get_tree().current_scene.add_child(missile)
	# FIXED: Changed from _apply_power_scale() to _apply_combat_scaling()
	missile._apply_combat_scaling()
	_flash()

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
