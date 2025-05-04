extends Button
class_name StoreItem

var item: PassiveItem

func set_item(new_item: PassiveItem) -> void:
	item = new_item
	
	# Set the button's modulate color
	self.modulate = item.store_color
	
	# Set the button's label text
	text = "%s - %d" % [item.name, item.price]
