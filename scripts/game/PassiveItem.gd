extends Resource
class_name PassiveItem

@export var id: String
@export var name: String
@export var description: String
@export var stat_modifiers: Dictionary = {}
@export var behavior_flags: Dictionary = {}
@export var icon: Texture
@export var store_color: Color = Color.WHITE
@export var price: int = 10
@export var rarity: String = "common"
@export var is_unique: bool = false

static func create_warp_detonator() -> PassiveItem:
	var item = PassiveItem.new()
	item.id = "warp_detonator"
	item.name = "Warp Detonator"
	item.description = "Blink causes explosion"
	item.stat_modifiers = {}
	item.behavior_flags = {"blink_explosion": true}
	item.icon = preload("res://assets/dummy-icon.jpg")
	item.store_color = Color.WHITE
	item.price = 20
	item.rarity = "epic"
	item.is_unique = true
	return item

static func create_reinforced_hull() -> PassiveItem:
	var item = PassiveItem.new()
	item.id = "reinforced_hull"
	item.name = "Reinforced Hull"
	item.description = "+50 Max Shield"
	item.stat_modifiers = {"max_shield": 50}
	item.behavior_flags = {}
	item.icon = preload("res://assets/dummy-icon.jpg")
	item.store_color = Color.WHITE
	item.price = 15
	item.rarity = "rare"
	item.is_unique = false
	return item

static func get_all_items() -> Array:
	return [
		create_warp_detonator(),
		create_reinforced_hull(),
		# Add more items below...
	]

static func get_item_by_id(id: String) -> PassiveItem:
	for item in get_all_items():
		if item.id == id:
			return item
	return null
