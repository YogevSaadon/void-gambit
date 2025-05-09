extends Button
class_name StoreItem

var item: PassiveItem

func set_item(new_item: PassiveItem) -> void:
	item = new_item

	# Show all text (name, description, price)
	text = "%s\n%s\n%d Credits" % [item.name, item.description, item.price]

	# Change all text color based on rarity
	self.add_theme_color_override("font_color", _get_text_color(item.rarity))

	# Disable button if player can’t afford
	var gm = get_tree().root.get_node_or_null("GameManager")
	disabled = gm == null or gm.coins < item.price


func purchase_item(pd: Node, gm: Node, pem: Node) -> bool:
	if gm.coins < item.price:
		return false
	gm.coins -= item.price
	pd.add_item(item)
	pem.initialize_from_player_data(pd)
	visible = false
	return true


func _get_text_color(rarity: String) -> Color:
	match rarity:
		"common":    return Color(1, 1, 1)       # white
		"uncommon":  return Color(0, 1, 0)       # green
		"rare":      return Color(0, 0.6, 1)     # light blue
		"epic":      return Color(0.6, 0, 1)     # purple
		"legendary": return Color(1, 0.6, 0)     # orange
		_:           return Color(1, 1, 1)       # fallback white
