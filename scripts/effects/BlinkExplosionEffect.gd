extends BehaviorEffect

@export var explosion_scene: PackedScene = preload("res://scenes/bullets/Explosion.tscn")

func activate(p, pd, pem) -> void:
	super.activate(p, pd, pem)
	if is_instance_valid(player):
		player.player_blinked.connect(_on_blink)

func deactivate() -> void:
	if is_instance_valid(player) \
	and player.player_blinked.is_connected(_on_blink):
		player.player_blinked.disconnect(_on_blink)
	super.deactivate()

func _on_blink(pos: Vector2) -> void:
	if not is_instance_valid(player):
		return
	var e := explosion_scene.instantiate()
	e.global_position = pos
	e.damage       = 30 * (1.0 + pd.get_stat("explosive_damage_percent"))
	e.radius       = 96
	e.crit_chance  = pd.get_stat("crit_chance")
	pem.get_tree().current_scene.add_child(e)
