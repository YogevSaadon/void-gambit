# scripts/actors/enemys/attacks/StarAttack.gd
extends Node2D
class_name StarAttack

@export var base_damage   : float = AttackConstants.STAR_ATTACK_DAMAGE
@export var shooting_range: float = AttackConstants.STAR_ATTACK_RANGE
@export var fire_interval : float = AttackConstants.STAR_FIRE_INTERVAL
@export var bullet_count  : int = AttackConstants.STAR_BULLET_COUNT
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
		_fire_circle_attack()
		_fire_timer = fire_interval

func _fire_circle_attack() -> void:
	if not muzzle or not bullet_scene:
		push_error("StarAttack: Missing muzzle or bullet scene")
		return

	# Fire bullets in all directions (360° circle)
	for i in bullet_count:
		var angle = (i / float(bullet_count)) * TAU
		var direction = Vector2(cos(angle), sin(angle))
		_fire_bullet_in_direction(direction)
	
	_flash()

func _fire_bullet_in_direction(direction: Vector2) -> void:
	var bullet := bullet_scene.instantiate()
	bullet.global_position = muzzle.global_position

	if bullet.has_method("set_direction"):
		bullet.call("set_direction", direction)
	else:
		if bullet is BaseBullet:
			var b := bullet as BaseBullet
			b.direction = direction
			b.damage    = _final_damage

	bullet.rotation = direction.angle()
	get_tree().current_scene.add_child(bullet)

func _find_parent_enemy() -> BaseEnemy:
	var p := get_parent()
	while p and not (p is BaseEnemy):
		p = p.get_parent()
	
	if not p:
		push_error("StarAttack: No BaseEnemy parent found")
	
	return p as BaseEnemy

func _update_player_cache() -> void:
	var player := EnemyUtils.get_player()
	if not player:
		_player_in_range = false
		return

	_player_pos = player.global_position
	_player_in_range = true  # Star ALWAYS shoots regardless of range

func _flash() -> void:
	if not weapon_sprite:
		return
	var tween := create_tween()
	tween.tween_property(weapon_sprite, "modulate", Color.WHITE, 0.05)
	tween.tween_property(weapon_sprite, "modulate", weapon_sprite.modulate, 0.10)
