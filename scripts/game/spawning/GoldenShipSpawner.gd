# scripts/game/spawning/GoldenShipSpawner.gd
extends RefCounted
class_name GoldenShipSpawner

const GOLDEN_SHIP_SCENE = preload("res://scenes/actors/enemys/GoldShip.tscn")

var current_level: int = 1

func generate_golden_ships(level: int, player_data: PlayerData) -> Array[PackedScene]:
	current_level = level
	var spawn_list: Array[PackedScene] = []
	spawn_list.append(GOLDEN_SHIP_SCENE)
	return spawn_list

func apply_tier_scaling_to_golden_ship(golden_ship: Node, level: int) -> void:
	if not golden_ship:
		return
	
	var tier_multiplier = PowerBudgetCalculator.get_tier_multiplier(level)
	
	if golden_ship.has_method("apply_tier_scaling"):
		golden_ship.apply_tier_scaling(level)
	else:
		var base_power = golden_ship.get_budget_power_level() if golden_ship.has_method("get_budget_power_level") else 1
		golden_ship.power_level = base_power * tier_multiplier
		# FIXED: Changed from _apply_power_scale() to _apply_combat_scaling()
		if golden_ship.has_method("_apply_combat_scaling"):
			golden_ship._apply_combat_scaling()

func get_total_golden_ship_value(level: int) -> int:
	var tier_multiplier = PowerBudgetCalculator.get_tier_multiplier(level)
	return tier_multiplier

func get_spawner_statistics() -> Dictionary:
	return {
		"level": current_level,
		"total_value": get_total_golden_ship_value(current_level),
		"tier_multiplier": PowerBudgetCalculator.get_tier_multiplier(current_level),
		"tier_name": PowerBudgetCalculator.get_tier_name(current_level)
	}
