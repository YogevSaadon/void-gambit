extends Node
class_name PlayerData

# Core player stats (modifiers from items apply here)
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

# Runtime state
var current_rerolls: int = 0
var passive_item_ids: Array[String] = []
var active_behavior_flags: Dictionary = {}

# Reset stats and all inventory/effects
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
	passive_item_ids.clear()
	active_behavior_flags.clear()

# Add passive item (handles unique logic)
func add_item(item: PassiveItem) -> void:
	var already_owned = passive_item_ids.has(item.id)
	if item.is_unique and already_owned:
		return

	passive_item_ids.append(item.id)

	for stat in item.stat_modifiers:
		if player_stats.has(stat):
			player_stats[stat] += item.stat_modifiers[stat]
		else:
			player_stats[stat] = item.stat_modifiers[stat]

	for flag in item.behavior_flags:
		if item.behavior_flags[flag]:
			active_behavior_flags[flag] = true

# Return actual item references
func get_passive_items() -> Array:
	var items: Array = []
	for id in passive_item_ids:
		var item = PassiveItem.get_item_by_id(id)
		if item:
			items.append(item)
	return items

# Check active behaviors
func has_behavior(flag: String) -> bool:
	return active_behavior_flags.has(flag)

# Sync HP/Shield back to data (after wave ends)
func sync_from_player(p: Node) -> void:
	player_stats["hp"] = p.health
	player_stats["shield"] = p.shield
