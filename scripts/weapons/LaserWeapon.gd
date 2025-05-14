extends ShooterWeapon
class_name LaserWeapon

var beam_scene: PackedScene = preload("res://scenes/bullets/PersistentLaserBeam.tscn")
var beam_instance: Node = null          # single live beam

# tell BaseWeapon to include laser-specific bonus
func _damage_type_key() -> String:
	return "laser_damage_percent"

func _fire_once(target: Node) -> void:
	# validate target
	if not is_instance_valid(target):
		return

	# spawn or refresh beam
	if beam_instance and beam_instance.is_inside_tree():
		beam_instance.set_beam_stats($Muzzle, target,
									 final_damage, final_crit, final_range)
		return

	beam_instance = beam_scene.instantiate()
	# add to main scene so weapon rotation doesn’t skew the beam
	get_tree().current_scene.add_child(beam_instance)
	beam_instance.set_beam_stats($Muzzle, target,
								 final_damage, final_crit, final_range)
