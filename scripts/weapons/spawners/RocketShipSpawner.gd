# scripts/weapons/spawner/RocketShipSpawner.gd
extends UniversalShipSpawner
class_name RocketShipSpawner

func _ready() -> void:
	# Set weapon type to rocket
	weapon_type = WeaponType.ROCKET
	super._ready()

func _damage_type_key() -> String:
	return "explosive_damage_percent"
