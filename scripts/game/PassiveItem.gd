extends Resource
class_name PassiveItem

@export var id            : String
@export var name          : String
@export var description   : String
@export var rarity        : String = "common"
@export var price         : int    = 10
@export var stackable     : bool   = true
@export var unique        : bool   = false
@export var category      : String = "stat"
@export var sources       : Array[String] = []

@export var stat_modifiers: Dictionary = {}
@export var behavior_scene: Resource    = null
@export var weapon_scene  : PackedScene = null

func get_rarity_color() -> Color:
	match rarity:
		"common":    return Color(1, 1, 1)
		"uncommon":  return Color(0, 1, 0)
		"rare":      return Color(0, 0.6, 1)
		"epic":      return Color(0.6, 0, 1)
		"legendary": return Color(1, 0.6, 0)
		_:           return Color(1, 1, 1)
