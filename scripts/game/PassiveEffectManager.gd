extends Node
class_name PassiveEffectManager

var active_effects: Dictionary = {}
var player_data: PlayerData = null

func reset() -> void:
	active_effects.clear()

func initialize_from_player_data(data: PlayerData) -> void:
	reset()
	player_data = data
	for flag in player_data.active_behavior_flags.keys():
		active_effects[flag] = true

func has_effect(effect_name: String) -> bool:
	return active_effects.has(effect_name)

func register_signals(player: Player) -> void:
	player.player_blinked.connect(_on_player_blinked)

func _on_player_blinked(position: Vector2) -> void:
	if has_effect("blink_explosion"):
		_trigger_blink_explosion(position)

func _trigger_blink_explosion(pos: Vector2) -> void:
	var explosion = preload("res://scenes/weapons/Explosion.tscn").instantiate()
	explosion.global_position = pos
	explosion.damage = 30.0
	explosion.radius = 96.0
	explosion.crit_chance = player_data.get_stat("crit_chance")
	explosion.damage_group = "Enemies"
	get_tree().current_scene.add_child(explosion)
