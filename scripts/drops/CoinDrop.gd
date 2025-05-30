# res://scripts/drops/CoinDrop.gd
extends DropPickup
class_name CoinDrop

func _on_picked_up() -> void:
	var gm := get_tree().get_first_node_in_group("GameManager")
	if gm and gm.has_method("add_coins"):
		gm.add_coins(value)
	queue_free()
