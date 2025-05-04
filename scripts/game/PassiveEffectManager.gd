extends Node
class_name PassiveEffectManager

var game_manager: Node = null  # reference to GameManager

var active_effects: Dictionary = {}

func enable_effect(effect_name: String) -> void:
	active_effects[effect_name] = true

func disable_effect(effect_name: String) -> void:
	active_effects.erase(effect_name)

func has_effect(effect_name: String) -> bool:
	return active_effects.has(effect_name)

func register_game_manager(gm: Node) -> void:
	game_manager = gm

func register_signals(player: Node) -> void:
	player.player_blinked.connect(_on_player_blinked)

func _on_player_blinked(position: Vector2) -> void:
	if has_effect("blink_explosion"):
		_trigger_blink_explosion(position)

func _trigger_blink_explosion(pos: Vector2) -> void:
	print("Explosion triggered at ", pos)
	# TODO: Replace with actual explosion node

func reset() -> void:
	active_effects.clear()

func add_item(item: PassiveItem) -> void:
	if not game_manager:
		push_error("PassiveEffectManager has no reference to GameManager")
		return

	for stat in item.stat_modifiers:
		if game_manager.player_stats.has(stat):
			game_manager.player_stats[stat] += item.stat_modifiers[stat]

	for effect_flag in item.behavior_flags:
		if item.behavior_flags[effect_flag]:
			enable_effect(effect_flag)
