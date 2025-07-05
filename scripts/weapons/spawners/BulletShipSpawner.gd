# scripts/weapons/spawner/BioShipSpawner.gd
extends UniversalShipSpawner
class_name BioShipSpawner

func _ready() -> void:
	# Set weapon type to bio
	weapon_type = WeaponType.BIO
	super._ready()

func _damage_type_key() -> String:
	return "bio_damage_percent"
