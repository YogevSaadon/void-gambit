extends Button
class_name StoreItem

var item: PassiveItem = null
var weapon: WeaponItem = null

func set_item_or_weapon(new_item) -> void:
	if new_item is PassiveItem:
		item = new_item
		weapon = null
		text = "%s\n%s\n%d Credits" % [item.name, item.description, item.price]
		self.add_theme_color_override("font_color", item.get_rarity_color())
	elif new_item is WeaponItem:
		weapon = new_item
		item = null
		text = "%s\n%s\n%d Credits" % [weapon.name, weapon.description, weapon.price]
		self.add_theme_color_override("font_color", weapon.get_rarity_color())
	else:
		push_error("StoreItem: Invalid item type passed to set_item_or_weapon")
		return
	
	# Update button disabled state based on price
	var gm = get_tree().root.get_node_or_null("GameManager")
	if gm:
		var price = item.price if item else weapon.price
		disabled = gm.credits < price

func set_item(new_item: PassiveItem) -> void:
	"""Legacy method for backward compatibility"""
	set_item_or_weapon(new_item)

func purchase_item(pd: PlayerData, gm: GameManager, pem: PassiveEffectManager) -> bool:
	var price = item.price if item else weapon.price
	
	if not gm.spend_credits(price):
		return false

	if item:
		# Purchase passive item
		pd.add_item(item)
		pem.initialize_from_player_data(pd)
		print("Purchased passive item: %s" % item.name)
	elif weapon:
		# Purchase weapon
		var success = pd.add_weapon(weapon)
		if not success:
			# Refund credits if weapon slots are full
			gm.add_credits(price)
			print("All weapon slots full, refunded %d credits" % price)
			return false
		print("Purchased weapon: %s" % weapon.name)
	else:
		push_error("StoreItem: No item or weapon to purchase")
		return false

	visible = false
	return true
