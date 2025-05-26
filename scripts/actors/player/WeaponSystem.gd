extends Node
class_name WeaponSystem

@export var num_slots := 6       # easy to make 7 later
var owner_player : Player = null # set once from Player.initialize()

# -- lifecycle --------------------------------------------------
func _ready() -> void:
	# ensure empty Node2D children exist
	for i in num_slots:
		var name := "Weapon%d" % i
		if not has_node(name):
			var slot := Node2D.new()
			slot.name = name
			add_child(slot)

# -- public API -------------------------------------------------
func get_slot(idx:int) -> Node2D:
	return get_node_or_null("Weapon%d" % idx)

func clear_all() -> void:
	for i in num_slots:
		var slot := get_slot(i)
		if slot:
			for c in slot.get_children():
				c.queue_free()

func equip(scene:PackedScene, idx:int) -> void:
	if scene == null: return
	var slot := get_slot(idx)
	if slot == null: return
	var w := scene.instantiate()
	w.owner_player = owner_player
	w.apply_weapon_modifiers(owner_player.player_data)
	slot.add_child(w)

func auto_fire(delta:float) -> void:
	for i in num_slots:
		var slot := get_slot(i)
		if slot:
			for w in slot.get_children():
				w.auto_fire(delta)
