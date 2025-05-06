extends Node
class_name PassiveEffectManager

var active_effects: Dictionary = {}
var player_data: Node = null

func reset() -> void:
	active_effects.clear()

func initialize_from_player_data(data: Node) -> void:
	reset()
	player_data = data
	for flag in player_data.active_behavior_flags.keys():
		active_effects[flag] = true

func has_effect(effect_name: String) -> bool:
	return active_effects.has(effect_name)

func register_signals(player: Node) -> void:
	player.player_blinked.connect(_on_player_blinked)

func _on_player_blinked(position: Vector2) -> void:
	if has_effect("blink_explosion"):
		_trigger_blink_explosion(position)

func _trigger_blink_explosion(pos: Vector2) -> void:
	print("Explosion triggered at ", pos)
