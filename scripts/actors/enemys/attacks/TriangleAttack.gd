# scripts/actors/enemys/attacks/TriangleAttack.gd
extends Node2D
class_name SingleShotWeapon

@export var base_damage   : float = AttackConstants.TRIANGLE_ATTACK_DAMAGE
@export var shooting_range: float = AttackConstants.TRIANGLE_ATTACK_RANGE
@export var fire_interval : float = AttackConstants.TRIANGLE_FIRE_INTERVAL
@export var bullet_scene  : PackedScene = preload("res://scenes/projectiles/enemy_projectiles/EnemyBullet.tscn")

var _owner_enemy  : BaseEnemy
var _fire_timer   : float = 0.0
var _range_timer  : float = 0.0
var _final_damage : float
var _player_pos   : Vector2
var _player_in_range : bool = false

@onready var muzzle        : Node2D   = $Muzzle
@onready var weapon_sprite : Sprite2D = $WeaponSprite

const RANGE_CHECK_INTERVAL := AttackConstants.RANGE_CHECK_INTERVAL

func _ready() -> void:
	_owner_enemy = _find_parent_enemy()
	if not _owner_enemy:
		return

	_final_damage = base_damage * _owner_enemy.power_level
	_fire_timer  = randf_range(0.0, fire_interval)
	_range_timer = randf_range(0.0, RANGE_CHECK_INTERVAL)

	if weapon_sprite:
		weapon_sprite.scale *= 1.0 + (_owner_enemy.power_level - 1.0) * 0.2

func _physics_process(delta: float) -> void:
	tick_attack(delta)

func tick_attack(delta: float) -> void:
	_fire_timer  -= delta
	_range_timer -= delta

	if _range_timer <= 0.0:
		_range_timer = RANGE_CHECK_INTERVAL
		_update_player_cache()

	if _player_in_range and _fire_timer <= 0.0:
		_fire_bullet()
		_fire_timer = fire_interval

func _fire_bullet() -> void:
	if not muzzle or not bullet_scene:
		push_error("SingleShotWeapon: Missing muzzle or bullet scene")
		return

	var bullet := bullet_scene.instantiate()
	bullet.global_position = muzzle.global_position
	var dir := (_player_pos - muzzle.global_position).normalized()

	if bullet.has_method("set_direction"):
		bullet.call("set_direction", dir)
	else:
		if bullet is BaseBullet:
			var b := bullet as BaseBullet
			b.direction = dir
			b.damage    = _final_damage

	bullet.rotation = dir.angle()
	get_tree().current_scene.add_child(bullet)
	_flash()

func _find_parent_enemy() -> BaseEnemy:
	var p := get_parent()
	while p and not (p is BaseEnemy):
		p = p.get_parent()
	
	if not p:
		push_error("SingleShotWeapon: No BaseEnemy parent found")
	
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
	tween.tween_property(weapon_sprite, "modulate", Color.WHITE, 0.05)
	tween.tween_property(weapon_sprite, "modulate", weapon_sprite.modulate, 0.10)
