extends Node
class_name PlayerData

signal item_added(item: PassiveItem)

# Base player stats (unchanging after run starts)
var base_stats: Dictionary = {
	"max_hp": 10000,
	"max_shield": 25,
	"speed": 200.0,
	"shield_recharge_rate": 5.0,
	"weapon_range": 500.0,
	"crit_chance": 0.05,
	"crit_damage": 1.5,
	"damage_percent": 0.0,
	"bullet_damage_percent": 0.0,
	"laser_damage_percent": 0.0,
	"explosive_damage_percent": 0.0,
	"bio_damage_percent": 0.0,
	"ship_damage_percent": 0.0,
	"blink_cooldown": 5.0,
	"blinks": 3,
	"rerolls_per_wave": 1,
	"luck": 0.0,
	"gold_drop_rate": 1.0,
	"ship_count": 10,
	"ship_range": 300.0,
	"bullet_attack_speed": 1.0,
	"laser_reflects": 10,
	"bio_spread_chance": 0.0,
	"explosion_radius_bonus": 0.0,
	"golden_ship_count": 1,  # Base: 1 golden ship per stage
	"armor": 0.0,            # Base: 0 armor (no damage reduction)
}

# Runtime state
var hp: float = 100.0
var shield: float = 25.0
var current_rerolls: int = 0

# Passive item memory
var passive_item_ids: Array[String] = []

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
