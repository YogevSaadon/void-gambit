extends ShooterWeapon
class_name LaserWeapon

@export var base_reflects : int = 0
var beam_scene : PackedScene = preload("res://scenes/bullets/ChainLaserBeamController.tscn")
var beam_instance : Node = null
var final_reflects : int = 0

func _damage_type_key() -> String:
	return "laser_damage_percent"

func apply_weapon_modifiers(pd: PlayerData) -> void:
	super.apply_weapon_modifiers(pd)
	final_reflects = base_reflects + pd.get_stat("laser_reflects")

func _physics_process(delta: float) -> void:
	if owner_player and owner_player.velocity.length() > 0.0:
		_stop_beam()
	super._physics_process(delta)

func _stop_beam():
	if beam_instance and beam_instance.is_inside_tree():
		beam_instance.queue_free()
	beam_instance = null

func _fire_once(target: Node) -> void:
	if not is_instance_valid(target):
		return
	if beam_instance and beam_instance.is_inside_tree():
		beam_instance.set_beam_stats(
			$Muzzle, target, final_damage, final_crit,
			final_range, final_reflects
		)
		return
	beam_instance = beam_scene.instantiate()
	get_tree().current_scene.add_child(beam_instance)
	beam_instance.set_beam_stats(
		$Muzzle, target, final_damage, final_crit,
		final_range, final_reflects
	)
