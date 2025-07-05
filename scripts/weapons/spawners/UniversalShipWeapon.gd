# scripts/weapons/ship/UniversalShipWeapon.gd
extends BaseShipWeapon
class_name UniversalShipWeapon

# ===== WEAPON TYPE ENUM =====
enum WeaponType { BULLET, LASER, ROCKET, BIO }

# ===== WEAPON CONFIGURATION =====
var weapon_type: WeaponType = WeaponType.BULLET

# ===== PROJECTILE SCENES =====
@export var bullet_scene: PackedScene = preload("res://scenes/projectiles/ship_projectiles/MiniShipBullet.tscn")
@export var missile_scene: PackedScene = preload("res://scenes/projectiles/ship_projectiles/MiniShipMissile.tscn")
@export var laser_beam_scene: PackedScene = preload("res://scenes/weapons/laser/ChainLaserBeamController.tscn")

# ===== WEAPON-SPECIFIC STATS =====
@export var bullet_speed: float = 1000.0
@export var rocket_explosion_radius: float = 64.0
@export var bio_dps: float = 15.0
@export var bio_duration: float = 3.0
@export var laser_reflects: int = 1

# ===== LASER SYSTEM =====
var laser_beam_instance: Node = null

# ===== MAIN CONFIGURATION =====
func configure_weapon_with_type(damage: float, fire_rate: float, crit_chance: float, type: WeaponType) -> void:
	"""Configure weapon with specific type"""
	weapon_type = type
	configure_weapon(damage, fire_rate, crit_chance)
	_setup_weapon_visuals()

func _setup_weapon_visuals() -> void:
	"""Change weapon appearance based on type"""
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		return
	
	match weapon_type:
		WeaponType.BULLET:
			sprite.modulate = Color(0.7, 0.4, 0.2, 1)  # Brown/orange for bullets
		WeaponType.LASER:
			sprite.modulate = Color(1, 0.2, 0.2, 1)    # Red for laser
		WeaponType.ROCKET:
			sprite.modulate = Color(1, 1, 0.2, 1)      # Yellow for rockets
		WeaponType.BIO:
			sprite.modulate = Color(0.2, 0.7, 0.2, 1)  # Green for bio

# ===== FIRING IMPLEMENTATION =====
func _fire_at_target(target: Node) -> void:
	"""Fire weapon based on type"""
	if not is_target_valid():
		return
	
	match weapon_type:
		WeaponType.BULLET:
			_fire_bullet(target)
		WeaponType.LASER:
			_fire_laser(target)
		WeaponType.ROCKET:
			_fire_rocket(target)
		WeaponType.BIO:
			_fire_bio(target)
	
	_create_muzzle_flash()

# ===== BULLET WEAPON =====
func _fire_bullet(target: Node) -> void:
	"""Fire bullet projectile"""
	if not bullet_scene:
		push_error("UniversalShipWeapon: bullet_scene not set!")
		return
	
	var bullet = bullet_scene.instantiate()
	bullet.global_position = get_muzzle_position()
	
	var direction = get_direction_to_target(target)
	bullet.direction = direction
	bullet.rotation = direction.angle()
	bullet.damage = final_damage
	bullet.speed = bullet_speed
	
	_setup_projectile_collision(bullet)
	get_tree().current_scene.add_child(bullet)

# ===== LASER WEAPON =====
func _fire_laser(target: Node) -> void:
	"""Fire/maintain laser beam"""
	if not laser_beam_scene:
		push_error("UniversalShipWeapon: laser_beam_scene not set!")
		return
	
	# Create laser beam if it doesn't exist
	if not laser_beam_instance or not is_instance_valid(laser_beam_instance):
		laser_beam_instance = laser_beam_scene.instantiate()
		get_tree().current_scene.add_child(laser_beam_instance)
	
	# Update laser beam target (using inherited laser stats)
	if laser_beam_instance and laser_beam_instance.has_method("set_beam_stats"):
		laser_beam_instance.set_beam_stats(
			muzzle, target, final_damage, final_crit_chance,
			400.0, laser_reflects  # Use inherited reflects from spawner
		)

# ===== ROCKET WEAPON =====
func _fire_rocket(target: Node) -> void:
	"""Fire rocket/missile projectile"""
	if not missile_scene:
		push_error("UniversalShipWeapon: missile_scene not set!")
		return
	
	var rocket = missile_scene.instantiate()
	rocket.global_position = get_muzzle_position()
	rocket.target_position = target.global_position
	
	# Configure rocket stats (using inherited explosion radius from spawner)
	rocket.damage = final_damage
	rocket.radius = rocket_explosion_radius  # Already scaled by spawner
	rocket.crit_chance = final_crit_chance
	
	get_tree().current_scene.add_child(rocket)

# ===== BIO WEAPON =====
func _fire_bio(target: Node) -> void:
	"""Apply bio damage over time"""
	if not target.has_node("StatusComponent"):
		return
	
	var status_component = target.get_node("StatusComponent")
	if status_component and status_component.has_method("apply_infection"):
		var bio_damage = final_damage * bio_dps / 10.0  # Convert burst damage to DPS
		status_component.apply_infection(bio_damage, bio_duration)

# ===== UTILITY METHODS =====
func _setup_projectile_collision(projectile: Node) -> void:
	"""Setup collision for projectiles"""
	if projectile.has_method("set_collision_properties"):
		projectile.set_collision_properties()
	else:
		# Fallback: set collision manually
		projectile.collision_layer = 1 << 4  # Player bullets layer
		projectile.collision_mask = 1 << 2   # Detect enemies layer

func _create_muzzle_flash() -> void:
	"""Visual muzzle flash effect"""
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		return
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.05)
	tween.tween_property(sprite, "modulate", _get_weapon_color(), 0.1)

func _get_weapon_color() -> Color:
	"""Get the base color for this weapon type"""
	match weapon_type:
		WeaponType.BULLET: return Color(0.7, 0.4, 0.2, 1)
		WeaponType.LASER: return Color(1, 0.2, 0.2, 1)
		WeaponType.ROCKET: return Color(1, 1, 0.2, 1)
		WeaponType.BIO: return Color(0.2, 0.7, 0.2, 1)
		_: return Color.WHITE

# ===== CLEANUP =====
func _exit_tree() -> void:
	# Clean up laser beam when weapon is destroyed
	if laser_beam_instance and is_instance_valid(laser_beam_instance):
		laser_beam_instance.queue_free()

# ===== DEBUG INFO =====
func get_weapon_debug_info() -> Dictionary:
	var base_info = super.get_weapon_debug_info()
	base_info["weapon_type"] = WeaponType.keys()[weapon_type]
	base_info["bullet_speed"] = bullet_speed
	base_info["rocket_radius"] = rocket_explosion_radius * 0.5  # Show actual mini size
	base_info["bio_dps"] = bio_dps
	base_info["laser_reflects"] = max(1, laser_reflects / 2)  # Show actual mini reflects
	return base_info
