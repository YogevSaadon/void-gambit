extends ShooterWeapon
class_name BulletWeapon

@export var bullet_scene: PackedScene = preload("res://scenes/bullets/Bullet.tscn")
@export var base_piercing : int = 0
var final_piercing        : int = 0

# ----- override to tell BaseWeapon which bonus to use -----
func _damage_type_key() -> String:
	return "bullet_damage_percent"
# ----------------------------------------------------------

func _fire_once(target: Node) -> void:
	var muzzle = $Muzzle
	if muzzle == null:
		push_error("BulletWeapon: Muzzle not found")
		return

	var b = bullet_scene.instantiate()
	b.position  = muzzle.global_position
	b.direction = (target.global_position - muzzle.global_position).normalized()
	b.rotation  = b.direction.angle()
	b.damage    = final_damage
	b.piercing  = final_piercing
	if b.has_method("set_collision_properties"):
		b.set_collision_properties()
	else:
		b.collision_layer = 1 << 4
		b.collision_mask  = 1 << 2
	get_tree().current_scene.add_child(b)

func apply_weapon_modifiers(pd: PlayerData) -> void:
	super.apply_weapon_modifiers(pd)  # handles damage, fire‑rate, etc.
	final_piercing = base_piercing + pd.get_stat("bullet_pierce")
