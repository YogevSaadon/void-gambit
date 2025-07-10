# scripts/actors/enemys/attacks/ConeAttack.gd
extends Node2D
class_name ConeAttack

# ───── TUNABLES ──────────────────────────────────────────────
@export var base_damage   : float       = 15.0
@export var shooting_range: float       = 500.0     # pixels
@export var fire_interval : float       = 3.0       # seconds between shots
@export var cone_angle    : float       = 45.0      # degrees - angle between the two shots
@export var bullet_scene  : PackedScene = preload(
	"res://scenes/projectiles/enemy_projectiles/EnemyBullet.tscn"
)

# ───── RUNTIME STATE ─────────────────────────────────────────
var _owner_enemy  : BaseEnemy
var _fire_timer   : float = 0.0
var _range_timer  : float = 0.0
var _final_damage : float
var _player_pos   : Vector2
var _player_in_range : bool = false

# ───── CHILD REFERENCES ─────────────────────────────────────
@onready var muzzle        : Node2D   = $Muzzle
@onready var weapon_sprite : Sprite2D = $WeaponSprite

# How often we re-check distance to player (seconds)
const RANGE_CHECK_INTERVAL := 0.2

func _ready() -> void:
	_owner_enemy = _find_parent_enemy()
	if not _owner_enemy:
		return

	# scale damage by enemy power level
	_final_damage = base_damage * _owner_enemy.power_level

	# randomise timers so waves of enemies don't fire in sync
	_fire_timer  = randf_range(0.0, fire_interval)
	_range_timer = randf_range(0.0, RANGE_CHECK_INTERVAL)

	# (optional) make the gun graphic bigger for stronger enemies
	if weapon_sprite:
		weapon_sprite.scale *= 1.0 + (_owner_enemy.power_level - 1.0) * 0.2

func _physics_process(delta: float) -> void:
	tick_attack(delta)

func tick_attack(delta: float) -> void:
	_fire_timer  -= delta
	_range_timer -= delta

	# periodically refresh distance cache
	if _range_timer <= 0.0:
		_range_timer = RANGE_CHECK_INTERVAL
		_update_player_cache()

	# shoot when ready
	if _player_in_range and _fire_timer <= 0.0:
		_fire_cone_attack()
		_fire_timer = fire_interval

func _find_parent_enemy() -> BaseEnemy:
	var p := get_parent()
	while p and not (p is BaseEnemy):
		p = p.get_parent()
	
	if not p:
		push_error("ConeAttack: No BaseEnemy parent found")
	
	return p as BaseEnemy

func _update_player_cache() -> void:
	var player := EnemyUtils.get_player()
	if not player:
		_player_in_range = false
		return

	_player_pos = player.global_position
	_player_in_range = _owner_enemy.global_position.distance_to(_player_pos) <= shooting_range

func _fire_cone_attack() -> void:
	if not muzzle or not bullet_scene:
		push_error("ConeAttack: Missing muzzle or bullet scene")
		return

	# ─── Calculate direction to player ───
	var to_player := (_player_pos - muzzle.global_position).normalized()
	
	# ─── Convert cone angle from degrees to radians ───
	var half_cone_rad := deg_to_rad(cone_angle * 0.5)
	
	# ─── Calculate the two shot directions (left and right of player) ───
	var left_angle := to_player.angle() - half_cone_rad
	var right_angle := to_player.angle() + half_cone_rad
	
	var left_dir := Vector2(cos(left_angle), sin(left_angle))
	var right_dir := Vector2(cos(right_angle), sin(right_angle))
	
	# ─── Fire left bullet ───
	_fire_bullet_in_direction(left_dir)
	
	# ─── Fire right bullet ───
	_fire_bullet_in_direction(right_dir)
	
	_flash()

func _fire_bullet_in_direction(direction: Vector2) -> void:
	# ─── Instantiate and place the projectile ───
	var bullet := bullet_scene.instantiate()
	bullet.global_position = muzzle.global_position

	# ─── Set bullet direction and properties ───
	if bullet.has_method("set_direction"):
		bullet.call("set_direction", direction)
	else:
		# …otherwise treat it as BaseBullet and assign the vars directly.
		if bullet is BaseBullet:
			var b := bullet as BaseBullet
			b.direction = direction
			b.damage    = _final_damage
		else:
			push_warning("Bullet doesn't expose direction; it will sit still!")

	bullet.rotation = direction.angle()

	# Add the projectile to the current scene (or to a dedicated 'Projectiles' node)
	get_tree().current_scene.add_child(bullet)

func _flash() -> void:
	if not weapon_sprite:
		return
	var tween := create_tween()
	tween.tween_property(weapon_sprite, "modulate", Color.WHITE, 0.05)
	tween.tween_property(weapon_sprite, "modulate", weapon_sprite.modulate, 0.10)
