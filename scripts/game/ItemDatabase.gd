extends Node
class_name ItemDatabase

var _items_by_id: Dictionary = {}

const ALLOWED_KEYS := [
	"id", "name", "description", "rarity", "price",
	"stackable", "category", "stat_modifiers",
	"behavior_scene", "weapon_scene"
]

func load_from_json(path: String = "res://data/items.json") -> void:
	_items_by_id.clear()

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("ItemDatabase: cannot open %s" % path)
		return

	var root: Variant = JSON.parse_string(file.get_as_text())
	if typeof(root) != TYPE_ARRAY:
		push_error("ItemDatabase: JSON root must be an array")
		return

	for dict in root:
		if typeof(dict) != TYPE_DICTIONARY:
			push_warning("ItemDatabase: skipping non-dictionary entry")
			continue

		var item := PassiveItem.new()

		for key in dict.keys():
			if key not in ALLOWED_KEYS:
				continue

			var value = dict[key]

			if key in ["behavior_scene", "weapon_scene"] \
			and typeof(value) == TYPE_STRING and value != "":
				var res := load(value)
				if res == null:
					push_warning("ItemDatabase: failed to load %s for key %s" % [value, key])
					continue
				value = res

			item.set(key, value)

		if item.id == "":
			push_warning("ItemDatabase: item missing 'id' – skipped")
			continue

		_items_by_id[item.id] = item


func get_item(id: String) -> PassiveItem:
	return _items_by_id.get(id)

func get_all_items() -> Array:
	return _items_by_id.values()
