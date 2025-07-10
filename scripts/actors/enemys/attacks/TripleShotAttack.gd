# scripts/actors/enemys/attacks/TripleShotAttack.gd
extends Node2D
class_name TripleShotAttack

# ───── TUNABLES ──────────────────────────────────────────────
@export var base_damage   : float       = 10.0      # Less than single shot (15)
@export var shooting_range: float       = 350.0     # Slightly less than Triangle
@export var burst_interval: float       = 3.0       # Time between burst starts
@export var shots_per_burst: int        = 3         # Number of shots in burst
@export var shot_delay    : float       = 0.15      # Delay between shots in burst
@export var spread_angle  : float       = 15.0      # Degrees of spread
@export var bullet_scene  : PackedScene = preload(
	"res://scenes/projectiles/enemy_projectiles/EnemyBullet.tscn"
)

# ───── RUNTIME STATE ─────────────────────────────────────────
var _owner_enemy  : BaseEnemy
var _burst_timer  : float = 0.0
var _shot_timer   : float = 0.0
var _shots_fired  : int = 0
var _in_burst     : bool = false
var _range_timer  : float = 0.0
var _final_damage : float
var _player_pos   : Vector2
var _player_in_range : bool = false

# ───── CHILD REFERENCES ─────────────────────────────────────
@onready var muzzle        : Node2D   = $Muzzle
@onready var weapon_sprite : Sprite2D = $WeaponSprite

const RANGE_CHECK_INTERVAL := 0.2

# ─────────────────────────────────────────────────────────────
#  LIFECYCLE
# ─────────────────────────────────────────────────────────────
func _ready() -> void:
	# GODOT SCENE TREE NAVIGATION: Find owning enemy via parent traversal
	_owner_enemy = _find_parent_enemy()
	if not _owner_enemy:
		push_error("TripleShotAttack: Failed to initialize - no BaseEnemy parent")
		return

	# Scale damage by enemy power level
	_final_damage = base_damage * _owner_enemy.power_level

	# Randomise timers
	_burst_timer = randf_range(0.0, burst_interval)
	_range_timer = randf_range(0.0, RANGE_CHECK_INTERVAL)

	# Make gun smaller for child ships (they're smaller enemies)
	if weapon_sprite:
		weapon_sprite.scale *= 0.8

func _physics_process(delta: float) -> void:
	tick_attack(delta)

# ─────────────────────────────────────────────────────────────
#  MAIN UPDATE
# ─────────────────────────────────────────────────────────────
func tick_attack(delta: float) -> void:
	_range_timer -= delta

	# Periodically check range
	if _range_timer <= 0.0:
		_range_timer = RANGE_CHECK_INTERVAL
		_update_player_cache()

	# Handle burst state
	if _in_burst:
		_shot_timer -= delta
		if _shot_timer <= 0.0 and _shots_fired < shots_per_burst:
			_fire_shot()
			_shots_fired += 1
			_shot_timer = shot_delay
			
		if _shots_fired >= shots_per_burst:
			_in_burst = false
			_shots_fired = 0
			_burst_timer = burst_interval
	else:
		_burst_timer -= delta
		if _burst_timer <= 0.0 and _player_in_range:
			_in_burst = true
			_shots_fired = 0
			_shot_timer = 0.0  # Fire first shot immediately

# ─────────────────────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────────────────────
func _find_parent_enemy() -> BaseEnemy:
	"""
	GODOT SCENE TREE NAVIGATION: Standard parent traversal pattern
	ARCHITECTURE: Components find their owners through scene hierarchy
	ERROR HANDLING: Explicit failure with detailed error message for debugging
	"""
	var p := get_parent()
	while p and not (p is BaseEnemy):
		p = p.get_parent()
	
	# EXPLICIT FAILURE: Better than silent null return for debugging
	if not p:
		var script_name = get_script().get_path().get_file()
		push_error("%s: No BaseEnemy found in parent hierarchy. Check scene structure." % script_name)
	
	return p as BaseEnemy

func _update_player_cache() -> void:
	var player := EnemyUtils.get_player()
	if not player:
		_player_in_range = false
		return

	_player_pos = player.global_position
	_player_in_range = _owner_enemy.global_position.distance_to(_player_pos) <= shooting_range

func _fire_shot() -> void:
	if not muzzle or not bullet_scene:
		return

	# Base direction to player
	var base_dir := (_player_pos - muzzle.global_position).normalized()
	
	# Calculate spread based on which shot this is
	var spread_offset = 0.0
	if shots_per_burst > 1:
		# -1, 0, 1 for 3 shots
		var shot_index = _shots_fired - (shots_per_burst / 2.0) + 0.5
		spread_offset = shot_index * spread_angle
	
	# Apply spread
	var spread_rad = deg_to_rad(spread_offset)
	var final_angle = base_dir.angle() + spread_rad
	var final_dir = Vector2(cos(final_angle), sin(final_angle))
	
	# Create bullet
	var bullet := bullet_scene.instantiate()
	bullet.global_position = muzzle.global_position

	if bullet.has_method("set_direction"):
		bullet.call("set_direction", final_dir)
	else:
		if bullet is BaseBullet:
			var b := bullet as BaseBullet
			b.direction = final_dir
			b.damage = _final_damage

	bullet.rotation = final_dir.angle()
	get_tree().current_scene.add_child(bullet)
	
	_flash()

func _flash() -> void:
	if not weapon_sprite:
		return
	var tween := create_tween()
	tween.tween_property(weapon_sprite, "modulate", Color.WHITE, 0.03)
	tween.tween_property(weapon_sprite, "modulate", weapon_sprite.modulate, 0.06)
