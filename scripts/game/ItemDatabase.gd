extends Node
class_name ItemDatabase

# Import WeaponItem class
const WeaponItem = preload("res://scripts/game/hangar/WeaponItem.gd")

var _items_by_id: Dictionary = {}
var _weapons_by_id: Dictionary = {}

const ALLOWED_KEYS := [
	"id", "name", "description", "rarity", "price",
	"stackable", "unique", "category", "stat_modifiers",
	"behavior_scene", "weapon_scene", "sources"
]

const WEAPON_ALLOWED_KEYS := [
	"id", "name", "description", "rarity", "price",
	"category", "sources", "weapon_scene", "weapon_type"
]

func load_from_json(path: String = "res://data/items.json") -> void:
	_items_by_id.clear()
	_weapons_by_id.clear()

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("ItemDatabase: cannot open %s" % path)
		return

	var root: Variant = JSON.parse_string(file.get_as_text())
	
	# Handle both old array format and new object format
	var items_array = []
	var weapons_array = []
	
	if typeof(root) == TYPE_ARRAY:
		# Old format: direct array
		items_array = root
	elif typeof(root) == TYPE_DICTIONARY:
		# New format: object with items and weapons arrays
		if root.has("items"):
			items_array = root["items"]
		if root.has("weapons"):
			weapons_array = root["weapons"]
	else:
		push_error("ItemDatabase: JSON must be array or object with 'items' field")
		return

	# Load items
	if typeof(items_array) == TYPE_ARRAY:
		_load_items(items_array)
	
	# Load weapons
	if typeof(weapons_array) == TYPE_ARRAY:
		_load_weapons(weapons_array)
		

func _load_items(items_array: Array) -> void:
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

func _load_weapons(weapons_array: Array) -> void:
	for dict in weapons_array:
		if typeof(dict) != TYPE_DICTIONARY:
			push_warning("ItemDatabase: skipping non-dictionary weapon entry")
			continue

		var weapon := WeaponItem.new()

		for key in dict.keys():
			if key not in WEAPON_ALLOWED_KEYS:
				continue

			var value = dict[key]

			if key == "weapon_scene" and typeof(value) == TYPE_STRING and value != "":
				var scene := load(value)
				if scene == null:
					push_warning("ItemDatabase: failed to load weapon scene %s" % value)
					continue
				weapon.weapon_scene = scene
			elif key == "sources" and typeof(value) == TYPE_ARRAY:
				var sources_array: Array[String] = []
				for source in value:
					sources_array.append(str(source))
				weapon.sources = sources_array
			else:
				weapon.set(key, value)

		if weapon.id == "":
			push_warning("ItemDatabase: weapon missing 'id' – skipped")
			continue

		_weapons_by_id[weapon.id] = weapon

# ===== ITEM METHODS =====
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

# ===== WEAPON METHODS =====
func get_weapons_for_source(source: String) -> Array:
	var available = []
	for weapon in _weapons_by_id.values():
		if weapon.sources and weapon.sources.has(source):
			available.append(weapon)
	return available

func get_store_weapons() -> Array:
	return get_weapons_for_source("store")

func get_slot_machine_weapons() -> Array:
	return get_weapons_for_source("slot_machine")

func get_weapon(id: String) -> WeaponItem:
	return _weapons_by_id.get(id)

func get_all_weapons() -> Array:
	return _weapons_by_id.values()
