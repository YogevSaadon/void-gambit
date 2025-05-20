extends Resource
class_name PassiveItem

@export var id            : String
@export var name          : String
@export var description   : String
@export var rarity        : String = "common"
@export var price         : int    = 10
@export var stackable     : bool   = true           # false ⇒ unique
@export var category      : String = "stat"         # "stat" | "behavior" | "weapon"

@export var stat_modifiers: Dictionary = {}         # for stat items
@export var behavior_scene: Resource    = null      # Script OR PackedScene
@export var weapon_scene  : PackedScene = null      # for weapon items
