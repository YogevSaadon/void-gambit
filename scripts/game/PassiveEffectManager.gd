extends Node
class_name PassiveEffectManager

## References set once per run
var player      : Player        = null
var player_data : PlayerData    = null

## Live BehaviourEffect nodes
var effects      : Array[Node]          = []
## Items picked up in Hangar before a player exists
var delayed_items: Array[PassiveItem]   = []


# ─────────────────────────────────────────────────────────
# PUBLIC API
# ─────────────────────────────────────────────────────────
func register_player(p: Player) -> void:
	player = p
	# Convert any delayed items into live effects now that we have a player
	for itm in delayed_items:
		_spawn_effect(itm)
	delayed_items.clear()


func initialize_from_player_data(pd: PlayerData) -> void:
	# disconnect old signal if any
	if player_data and player_data.is_connected("item_added", _on_item_added):
		player_data.item_added.disconnect(_on_item_added)

	player_data = pd
	player_data.item_added.connect(_on_item_added)

	# rebuild effects (fresh hangar reload)
	_clear_effects()
	for itm in player_data.get_passive_items():
		_apply_item(itm)


func reset() -> void:
	_clear_effects()
	delayed_items.clear()

	if player_data and player_data.is_connected("item_added", _on_item_added):
		player_data.item_added.disconnect(_on_item_added)

	player_data = null
	player      = null


# ─────────────────────────────────────────────────────────
# INTERNAL HELPERS
# ─────────────────────────────────────────────────────────
func _on_item_added(itm: PassiveItem) -> void:
	_apply_item(itm)


func _apply_item(itm: PassiveItem) -> void:
	if itm.category != "behavior" or itm.behavior_scene == null:
		return

	if player == null:
		delayed_items.append(itm)   # hangar: wait for player
	else:
		_spawn_effect(itm)


func _spawn_effect(itm: PassiveItem) -> void:
	var eff: Node

	if itm.behavior_scene is Script:
		eff = (itm.behavior_scene as Script).new()
	elif itm.behavior_scene is PackedScene:
		eff = (itm.behavior_scene as PackedScene).instantiate()
	else:
		push_warning("Invalid behavior_scene for item %s" % itm.id)
		return

	add_child(eff)
	eff.activate(player, player_data, self)
	effects.append(eff)


func _clear_effects() -> void:
	for eff in effects:
		if eff != null and eff.has_method("deactivate"):
			eff.deactivate()
	effects.clear()
