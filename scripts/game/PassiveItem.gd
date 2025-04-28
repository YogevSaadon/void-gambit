extends Resource
class_name PassiveItem

@export var name: String
@export var description: String
@export var stat_modifiers: Dictionary = {}
@export var behavior_flags: Dictionary = {}

static func create_warp_detonator() -> PassiveItem:
	var item = PassiveItem.new()
	item.name = "Warp Detonator"
	item.description = "Blink causes explosion"
	item.stat_modifiers = {}
	item.behavior_flags = {"blink_explosion": true}
	return item

static func create_reinforced_hull() -> PassiveItem:
	var item = PassiveItem.new()
	item.name = "Reinforced Hull"
	item.description = "+50 Max Shield"
	item.stat_modifiers = {"max_shield": 50}
	item.behavior_flags = {}
	return item

static func get_all_items() -> Array:
	return [
		create_warp_detonator(),
		create_reinforced_hull(),
		# Add more here
	]
