# scripts/weapons/spawner/BulletShipSpawner.gd
extends UniversalShipSpawner
class_name BulletShipSpawner

func _ready() -> void:
	# Set weapon type to bullet
	weapon_type = WeaponType.BULLET
	super._ready()

func _damage_type_key() -> String:
	return "bullet_damage_percent"
