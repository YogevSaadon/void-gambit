extends Node
class_name PlayerData

var player_stats: Dictionary = {
	"max_hp": 100,
	"hp": 100,
	"max_shield": 25,
	"shield": 25,
	"speed": 200.0,
	"shield_recharge_rate": 5.0,
	"base_fire_rate": 2.0,
	"attack_speed": 1.0,
	"weapon_range": 500.0,
	"crit_chance": 5.0,
	"piercing": 0,
	"blink_cooldown": 5.0,
	"blinks": 3,
	"rerolls_per_wave": 1,
}

var current_rerolls: int = 0
var passive_item_names: Array[String] = []
var active_behavior_flags: Dictionary = {}

func reset() -> void:
	player_stats = {
		"max_hp": 100,
		"hp": 100,
		"max_shield": 25,
		"shield": 25,
		"speed": 200.0,
		"shield_recharge_rate": 5.0,
		"base_fire_rate": 2.0,
		"attack_speed": 1.0,
		"weapon_range": 500.0,
		"crit_chance": 5.0,
		"piercing": 0,
		"blink_cooldown": 5.0,
		"blinks": 3,
		"rerolls_per_wave": 1,
	}
	current_rerolls = 0
	passive_item_names.clear()
	active_behavior_flags.clear()

func add_item(item: PassiveItem) -> void:
	if item.name in passive_item_names:
		return

	passive_item_names.append(item.name)

	for stat in item.stat_modifiers:
		if player_stats.has(stat):
			player_stats[stat] += item.stat_modifiers[stat]
		else:
			print("⚠ New stat added to player_stats: ", stat)
			player_stats[stat] = item.stat_modifiers[stat]

	for flag in item.behavior_flags:
		if item.behavior_flags[flag]:
			active_behavior_flags[flag] = true

func get_passive_items() -> Array:
	var items: Array = []
	for name in passive_item_names:
		var item = PassiveItem.get_item_by_name(name)
		if item:
			items.append(item)
	return items

func has_behavior(flag: String) -> bool:
	return active_behavior_flags.has(flag)

func sync_from_player(p: Node) -> void:
	player_stats["hp"] = p.health
	player_stats["shield"] = p.shield
