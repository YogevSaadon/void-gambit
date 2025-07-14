extends Node
class_name ItemDatabase

var _items_by_id: Dictionary = {}

const ALLOWED_KEYS := [
	"id", "name", "description", "rarity", "price",
	"stackable", "unique", "category", "stat_modifiers",
	"behavior_scene", "weapon_scene", "sources"
]

func load_from_json(path: String = "res://data/items.json") -> void:
	_items_by_id.clear()

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("ItemDatabase: cannot open %s" % path)
		return

	var root: Variant = JSON.parse_string(file.get_as_text())
	
	# Handle both old array format and new object format
	var items_array = []
	if typeof(root) == TYPE_ARRAY:
		# Old format: direct array
		items_array = root
	elif typeof(root) == TYPE_DICTIONARY and root.has("items"):
		# New format: object with items array
		items_array = root["items"]
	else:
		push_error("ItemDatabase: JSON must be array or object with 'items' field")
		return
	if typeof(items_array) != TYPE_ARRAY:
		push_error("ItemDatabase: 'items' must be an array")
		return

	for dict in items_array:
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
			
			# Special handling for sources array
			if key == "sources" and typeof(value) == TYPE_ARRAY:
				var sources_array: Array[String] = []
				for source in value:
					sources_array.append(str(source))
				item.sources = sources_array
			else:
				item.set(key, value)

		if item.id == "":
			push_warning("ItemDatabase: item missing 'id' – skipped")
			continue

		_items_by_id[item.id] = item

func get_items_for_source(source: String, owned_ids: Array = []) -> Array:
	var available = []
	for item in _items_by_id.values():
		if not item.sources or not item.sources.has(source):
			continue
			
		if item.unique and owned_ids.has(item.id):
			continue
			
		if not item.stackable and owned_ids.has(item.id):
			continue
			
		available.append(item)
	
	return available

func get_store_items(owned_ids: Array = []) -> Array:
	return get_items_for_source("store", owned_ids)

func get_slot_machine_items(owned_ids: Array = []) -> Array:
	return get_items_for_source("slot_machine", owned_ids)

func get_item(id: String) -> PassiveItem:
	return _items_by_id.get(id)

func get_all_items() -> Array:
	return _items_by_id.values()
