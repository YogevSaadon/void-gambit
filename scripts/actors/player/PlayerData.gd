extends Node
class_name PlayerData

signal item_added(item: PassiveItem)

# Base player stats (unchanging after run starts)
var base_stats: Dictionary = {
	"max_hp": 10000,
	"max_shield": 250,
	"speed": 150.0,
	"shield_recharge_rate": 0.0,
	"weapon_range": 300.0,
	"crit_chance": 0.05,
	"crit_damage": 1.5,
	"damage_percent": 0.0,
	"bullet_damage_percent": 0.0,
	"laser_damage_percent": 0.0,
	"explosive_damage_percent": 0.0,
	"bio_damage_percent": 0.0,
	"ship_damage_percent": 0.0,
	"blink_cooldown": 8.0,
	"blinks": 1,
	"rerolls_per_wave": 1,
	"luck": 0.0,
	"gold_drop_rate": 1.0,
	"ship_count": 1,
	"ship_range": 300.0,
	"bullet_attack_speed": 1.0,
	"laser_reflects": 0,
	"bio_spread_chance": 0.0,
	"explosion_radius_bonus": 0.0,
	"golden_ship_count": 1, 
	"armor": 0.0,            
}

# Runtime state
var hp: float = 100.0
var shield: float = 25.0
var current_rerolls: int = 0

# Passive item memory
var passive_item_ids: Array[String] = []

# Weapon inventory (6 slots to match your weapon system)
var equipped_weapons: Array[String] = []  # Weapon IDs
const MAX_WEAPON_SLOTS = 6

# Dynamic modifier layers
var additive_mods: Dictionary = {}
var percent_mods: Dictionary = {}

# ====== PUBLIC API ======

func reset() -> void:
	hp = base_stats["max_hp"]
	shield = base_stats["max_shield"]
	current_rerolls = 0
	passive_item_ids.clear()
	additive_mods.clear()
	percent_mods.clear()
	
	# Weapon reset
	equipped_weapons.clear()
	equipped_weapons.resize(MAX_WEAPON_SLOTS)
	equipped_weapons[0] = "basic_bullet_weapon"  # Default weapon

func add_item(item: PassiveItem) -> void:
	if (not item.stackable) and passive_item_ids.has(item.id):
		return

	passive_item_ids.append(item.id)

	for stat in item.stat_modifiers:
		var mod = item.stat_modifiers[stat]
		if typeof(mod) == TYPE_DICTIONARY:
			additive_mods[stat] = additive_mods.get(stat, 0.0) + mod.get("add", 0.0)
			percent_mods[stat] = percent_mods.get(stat, 0.0) + mod.get("percent", 0.0)
		else:
			additive_mods[stat] = additive_mods.get(stat, 0.0) + mod
	emit_signal("item_added", item)

func get_stat(stat: String) -> float:
	var base = base_stats.get(stat, 0.0)
	var add = additive_mods.get(stat, 0.0)
	var pct = percent_mods.get(stat, 0.0)
	return (base + add) * (1.0 + pct)

func get_passive_items() -> Array:
	var db = get_tree().root.get_node("ItemDatabase")
	var items : Array = []
	for id in passive_item_ids:
		var item = db.get_item(id)
		if item:
			items.append(item)
	return items

func sync_from_player(p: Node) -> void:
	hp = p.health
	shield = p.shield

# ====== WEAPON MANAGEMENT ======

func add_weapon(weapon: WeaponItem) -> bool:
	"""Try to equip weapon in first empty slot. Returns true if successful."""
	for i in range(MAX_WEAPON_SLOTS):
		if equipped_weapons[i] == "" or equipped_weapons[i] == null:
			equipped_weapons[i] = weapon.id
			print("Equipped %s in slot %d" % [weapon.name, i])
			return true
	
	print("All weapon slots full, cannot equip %s" % weapon.name)
	return false

func remove_weapon(slot_index: int) -> void:
	"""Remove weapon from specific slot (for future use)"""
	if slot_index >= 0 and slot_index < MAX_WEAPON_SLOTS:
		if slot_index == 0:
			equipped_weapons[slot_index] = "basic_bullet_weapon"  # Keep default
		else:
			equipped_weapons[slot_index] = ""

func get_equipped_weapons() -> Array[WeaponItem]:
	"""Get array of actual WeaponItem objects"""
	var weapons: Array[WeaponItem] = []
	var db = get_tree().root.get_node_or_null("ItemDatabase")
	if not db:
		push_error("PlayerData: ItemDatabase not found")
		return weapons
	
	for weapon_id in equipped_weapons:
		if weapon_id != "" and weapon_id != null:
			var weapon = db.get_weapon(weapon_id)
			if weapon:
				weapons.append(weapon)
			else:
				weapons.append(null)
		else:
			weapons.append(null)
	
	return weapons

func get_equipped_weapon_scenes() -> Array[PackedScene]:
	"""Get array of weapon scenes for Player.equip_weapon()"""
	var scenes: Array[PackedScene] = []
	var equipped = get_equipped_weapons()
	
	for weapon in equipped:
		if weapon and weapon.weapon_scene:
			scenes.append(weapon.weapon_scene)
		else:
			scenes.append(null)
	
	return scenes
