extends ShooterWeapon
class_name LaserWeapon

@export var base_reflects : int = 0
@export var laser_damage: float = round(base_damage * 0.05)  # 1.0
var beam_scene : PackedScene = preload("res://scenes/weapons/laser/ChainLaserBeamController.tscn")
var beam_instance : Node = null
var final_reflects : int = 0

func _damage_type_key() -> String:
	return "laser_damage_percent"

func apply_weapon_modifiers(pd: PlayerData) -> void:
	super.apply_weapon_modifiers(pd)
	final_reflects = base_reflects + pd.get_stat("laser_reflects")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func _stop_beam():
	if beam_instance and beam_instance.is_inside_tree():
		beam_instance.queue_free()
	beam_instance = null

func _fire_once(target: Node) -> void:
	if not is_instance_valid(target):
		return
	
	# Calculate laser damage with bonuses (like bullet weapon does)
	var damage = laser_damage * (1.0 + owner_player.player_data.get_stat("damage_percent") 
								+ owner_player.player_data.get_stat("laser_damage_percent"))
	
	if beam_instance and beam_instance.is_inside_tree():
		beam_instance.set_beam_stats(
			$Muzzle, target, damage, final_crit,
			final_range, final_reflects
		)
		return
	beam_instance = beam_scene.instantiate()
	get_tree().current_scene.add_child(beam_instance)
	beam_instance.set_beam_stats(
		$Muzzle, target, damage, final_crit,
		final_range, final_reflects
	)
