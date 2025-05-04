extends Button
class_name StoreItem

var item: PassiveItem

func set_item(new_item: PassiveItem) -> void:
	item = new_item
	
	self.modulate = item.store_color
	text = "%s - %d" % [item.name, item.price]

	var gm = get_tree().root.get_node_or_null("GameManager")
	disabled = gm == null or gm.coins < item.price
