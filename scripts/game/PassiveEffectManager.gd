extends Node
class_name PassiveEffectManager

var active_effects: Dictionary = {}

func enable_effect(effect_name: String) -> void:
	active_effects[effect_name] = true

func disable_effect(effect_name: String) -> void:
	active_effects.erase(effect_name)

func has_effect(effect_name: String) -> bool:
	return active_effects.has(effect_name)

func register_signals(player: Node) -> void:
	player.player_blinked.connect(_on_player_blinked)

func _on_player_blinked(position: Vector2) -> void:
	if has_effect("blink_explosion"):
		_trigger_blink_explosion(position)

func _trigger_blink_explosion(pos: Vector2) -> void:
	print("Explosion triggered at ", pos)
	# Real explosion logic to spawn area damage node here
