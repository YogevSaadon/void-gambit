extends ShooterWeapon
class_name LaserWeapon

var beam_scene: PackedScene = preload("res://scenes/bullets/PersistentLaserBeam.tscn")
var beam_instance      : Node = null      # keeps one live beam

# tell BaseWeapon to include laser_damage_percent in damage calculation
func _damage_type_key() -> String:
	return "laser_damage_percent"

func _fire_once(target: Node) -> void:
	if beam_scene == null:
		push_error("LaserWeapon: beam_scene missing")
		return

	# Beam already active → just refresh its stats/target
	if beam_instance and beam_instance.is_inside_tree():
		beam_instance.set_beam_stats($Muzzle, target,
									 final_damage, final_crit, final_range)
		return

	# Spawn a new persistent beam
	beam_instance = beam_scene.instantiate()
	add_child(beam_instance)   # keep under weapon so it dies with weapon
	beam_instance.set_beam_stats($Muzzle, target,
								 final_damage, final_crit, final_range)
