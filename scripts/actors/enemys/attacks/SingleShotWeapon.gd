# scripts/actors/enemys/attacks/EnemyWeapon.gd
extends Node2D
class_name SingleShotWeapon

# ====== Weapon Configuration ======
@export var base_damage: float = 15.0
@export var shooting_range: float = 400.0
@export var fire_interval: float = 3.0
@export var bullet_scene: PackedScene = preload("res://scenes/projectiles/enemy_projectiles/EnemyBullet.tscn")

# ====== Runtime Variables ======
var owner_enemy: BaseEnemy = null
var fire_timer: float = 0.0
var final_damage: float = 0.0
var final_range: float = 0.0

# ====== Performance Optimization ======
var range_check_timer: float = 0.0
var cached_player_in_range: bool = false
var cached_player_position: Vector2 = Vector2.ZERO

# ====== Nodes ======
@onready var muzzle: Node2D = $Muzzle
@onready var weapon_sprite: Sprite2D = $WeaponSprite

# ====== Performance Intervals ======
const RANGE_CHECK_INTERVAL: float = 0.2

func _enter_tree() -> void:
	# Find the enemy parent (could be direct parent or grandparent)
	var parent = get_parent()
	while parent != null and not (parent is BaseEnemy):
		parent = parent.get_parent()
	
	owner_enemy = parent as BaseEnemy
	assert(owner_enemy != null, "EnemyWeapon must be child of BaseEnemy")

func _ready() -> void:
	# Apply enemy power scaling
	_apply_enemy_modifiers()
	
	# Randomize initial fire timer
	fire_timer = randf() * fire_interval
	range_check_timer = randf() * RANGE_CHECK_INTERVAL
	
	# Verify nodes exist
	if muzzle == null:
		push_error("EnemyWeapon: Muzzle node not found")
	if weapon_sprite == null:
		push_warning("EnemyWeapon: WeaponSprite node not found")

# This gets called by BaseEnemy._physics_process() because it looks for tick_attack()
func tick_attack(delta: float) -> void:
	# Update timers
	fire_timer -= delta
	range_check_timer -= delta
	
	# Check range periodically
	if range_check_timer <= 0.0:
		range_check_timer = RANGE_CHECK_INTERVAL
		_update_player_range_cache()
	
	# Fire when ready and player in range
	if cached_player_in_range and fire_timer <= 0.0:
		_fire_at_player()
		fire_timer = fire_interval

func _apply_enemy_modifiers() -> void:
	"""Scale weapon stats based on enemy power level"""
	if owner_enemy == null:
		final_damage = base_damage
		final_range = shooting_range
		return
	
	# Scale damage with power level
	final_damage = base_damage * owner_enemy.power_level
	final_range = shooting_range
	
	# Optional: Scale weapon sprite size with power level
	if weapon_sprite:
		var scale_factor = 1.0 + (owner_enemy.power_level - 1) * 0.2  # 20% bigger per power level
		weapon_sprite.scale = weapon_sprite.scale * scale_factor

func _update_player_range_cache() -> void:
	var player = EnemyUtils.get_player()
	if player == null:
		cached_player_in_range = false
		return
	
	var distance = owner_enemy.global_position.distance_to(player.global_position)
	cached_player_in_range = distance <= final_range
	
	if cached_player_in_range:
		cached_player_position = player.global_position

func _fire_at_player() -> void:
	if muzzle == null or bullet_scene == null:
		return
	
	# Create bullet at muzzle position
	var bullet = bullet_scene.instantiate()
	bullet.global_position = muzzle.global_position
	
	# Aim at cached player position
	var direction = (cached_player_position - muzzle.global_position).normalized()
	bullet.direction = direction
	bullet.rotation = direction.angle()
	bullet.damage = final_damage
	
	# Add to scene
	get_tree().current_scene.add_child(bullet)
	
	# Optional: Add muzzle flash effect
	_show_muzzle_flash()

func _show_muzzle_flash() -> void:
	"""Optional visual effect when firing"""
	if weapon_sprite == null:
		return
	
	# Quick flash effect
	var original_modulate = weapon_sprite.modulate
	weapon_sprite.modulate = Color.WHITE
	
	var tween = create_tween()
	tween.tween_property(weapon_sprite, "modulate", original_modulate, 0.1)

# ====== Debug Helpers ======
func get_time_until_next_shot() -> float:
	return max(0.0, fire_timer)

func is_player_in_range() -> bool:
	return cached_player_in_range
