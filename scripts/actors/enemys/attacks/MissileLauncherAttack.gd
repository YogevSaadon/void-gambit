# scripts/actors/enemys/attacks/MissileLauncherAttack.gd
extends Node2D
class_name MissileLauncherAttack

# ───── TUNABLES ──────────────────────────────────────────────
@export var shooting_range: float       = 1000.0    # Very long range launcher
@export var fire_interval : float       = 5.0       # Slow but dangerous
@export var missile_scene  : PackedScene = preload(
	"res://scenes/actors/enemys/EnemyMissle.tscn"
)

# ───── RUNTIME STATE ─────────────────────────────────────────
var _owner_enemy  : BaseEnemy
var _fire_timer   : float = 0.0
var _range_timer  : float = 0.0
var _player_pos   : Vector2
var _player_in_range : bool = false

# ───── CHILD REFERENCES ─────────────────────────────────────
@onready var muzzle        : Node2D   = $Muzzle
@onready var weapon_sprite : Sprite2D = $WeaponSprite

const RANGE_CHECK_INTERVAL := 0.2

func _ready() -> void:
	_owner_enemy = _find_parent_enemy()
	assert(_owner_enemy, "MissileLauncherAttack must be inside a BaseEnemy scene")

	# Randomise timers so enemies don't fire in sync
	_fire_timer  = randf_range(0.0, fire_interval)
	_range_timer = randf_range(0.0, RANGE_CHECK_INTERVAL)

	# Make launcher bigger for stronger enemies
	if weapon_sprite:
		weapon_sprite.scale *= 1.0 + (_owner_enemy.power_level - 1.0) * 0.3

func _physics_process(delta: float) -> void:
	tick_attack(delta)

func tick_attack(delta: float) -> void:
	_fire_timer  -= delta
	_range_timer -= delta

	# Periodically refresh distance cache
	if _range_timer <= 0.0:
		_range_timer = RANGE_CHECK_INTERVAL
		_update_player_cache()

	# Launch missile when ready
	if _player_in_range and _fire_timer <= 0.0:
		_launch_missile()
		_fire_timer = fire_interval

func _launch_missile() -> void:
	if not muzzle or not missile_scene:
		push_error("MissileLauncherAttack: Missing muzzle or missile scene")
		return

	# Create missile at muzzle position
	var missile = missile_scene.instantiate()
	missile.global_position = muzzle.global_position
	
	# Pass power level from Diamond to missile
	missile.power_level = _owner_enemy.power_level
	
	# Add missile to scene
	get_tree().current_scene.add_child(missile)
	
	# Apply power scaling after adding to scene
	missile._apply_power_scale()
	
	print("Diamond launched missile with power level %d" % missile.power_level)
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
	tween.tween_property(weapon_sprite, "modulate", Color.WHITE, 0.1)
	tween.tween_property(weapon_sprite, "modulate", weapon_sprite.modulate, 0.2)
