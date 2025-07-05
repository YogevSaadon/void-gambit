# scripts/weapons/spawner/LaserShipSpawner.gd
extends UniversalShipSpawner
class_name LaserShipSpawner

func _ready() -> void:
	# Set weapon type to laser
	weapon_type = WeaponType.LASER
	super._ready()

func _damage_type_key() -> String:
	return "laser_damage_percent"
