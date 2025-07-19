# res://scripts/weapons/BioWeapon.gd
extends ShooterWeapon
class_name BioWeapon

@onready var pd = get_tree().root.get_node("PlayerData")

@export var base_dps: float = round(base_damage / 3.0)  # 7.0
@export var base_duration: float = 3.0

func _damage_type_key() -> String:
	return "bio_damage_percent"

func apply_weapon_modifiers(player_data: PlayerData) -> void:
	# keep ShooterWeapon's range / cooldown scaling
	super.apply_weapon_modifiers(player_data)

func _fire_once(target: Node) -> void:
	if not is_instance_valid(target):
		return

	var dps = base_dps * (1.0 + pd.get_stat("damage_percent")
								+ pd.get_stat("bio_damage_percent"))

	target.get_node("StatusComponent").apply_infection(dps, base_duration)
