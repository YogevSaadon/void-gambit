# scripts/game/hangar/WeaponItem.gd
extends Resource
class_name WeaponItem

@export var id: String
@export var name: String
@export var description: String
@export var rarity: String = "common"
@export var price: int = 10
@export var category: String = "weapon"
@export var sources: Array[String] = []

@export var weapon_scene: PackedScene
@export var weapon_type: String = "bullet"  # bullet, laser, rocket, bio, ship

func get_rarity_color() -> Color:
	match rarity:
		"common":    return Color(1, 1, 1)
		"uncommon":  return Color(0, 1, 0)
		"rare":      return Color(0, 0.6, 1)
		"epic":      return Color(0.6, 0, 1)
		"legendary": return Color(1, 0.6, 0)
		_:           return Color(1, 1, 1)
