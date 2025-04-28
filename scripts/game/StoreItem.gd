extends Button
class_name StoreItem

var item: PassiveItem

@onready var icon_texture = $IconTexture  # Assumes you have a TextureRect child named IconTexture

func set_item(new_item: PassiveItem) -> void:
	item = new_item
	if item.icon:
		icon_texture.texture = item.icon
	else:
		icon_texture.texture = null  # If no icon assigned
