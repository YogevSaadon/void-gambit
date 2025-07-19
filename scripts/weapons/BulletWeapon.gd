extends ShooterWeapon
class_name BulletWeapon

@export var bullet_damage: float = base_damage  
@export var bullet_scene: PackedScene = preload("res://scenes/projectiles/player_projectiles/PlayerBullet.tscn")

# ----- override to tell BaseWeapon which bonuses to use -----
func _damage_type_key() -> String:
	return "bullet_damage_percent"

func _fire_rate_stat_key() -> String:
	return "bullet_attack_speed"  # Only bullets scale with attack speed

func _fire_once(target: Node) -> void:
	var muzzle = $Muzzle
	if muzzle == null:
		push_error("BulletWeapon: Muzzle not found")
		return

	var b = bullet_scene.instantiate()
	b.position  = muzzle.global_position
	b.direction = (target.global_position - muzzle.global_position).normalized()
	b.rotation  = b.direction.angle()
	
	# Use custom bullet damage instead of final_damage
	var damage = bullet_damage * (1.0 + owner_player.player_data.get_stat("damage_percent") 
								+ owner_player.player_data.get_stat("bullet_damage_percent"))
	b.damage = damage
	
	if b.has_method("set_collision_properties"):
		b.set_collision_properties()
	else:
		b.collision_layer = 1 << 4
		b.collision_mask  = 1 << 2
	get_tree().current_scene.add_child(b)
