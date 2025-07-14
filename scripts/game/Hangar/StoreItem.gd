extends Button
class_name StoreItem

var item: PassiveItem

func set_item(new_item: PassiveItem) -> void:
	item = new_item
	text = "%s\n%s\n%d Credits" % [item.name, item.description, item.price]
	self.add_theme_color_override("font_color", item.get_rarity_color())

	var gm = get_tree().root.get_node_or_null("GameManager")
	disabled = gm == null or gm.credits < item.price

func purchase_item(pd: PlayerData, gm: GameManager, pem: PassiveEffectManager) -> bool:
	if not gm.spend_credits(item.price):
		return false

	pd.add_item(item)
	pem.initialize_from_player_data(pd)

	visible = false
	return true
