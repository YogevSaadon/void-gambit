# res://scripts/drops/CreditDrop.gd
extends DropPickup
class_name CreditDrop

func _on_picked_up() -> void:
	var gm := get_tree().get_first_node_in_group("GameManager")
	if gm and gm.has_method("add_credits"):
		gm.add_credits(value)
	queue_free()
