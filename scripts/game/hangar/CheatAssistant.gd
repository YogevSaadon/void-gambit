# scripts/game/Hangar/CheatAssistant.gd
extends Node
class_name CheatAssistant

static func add_cheat_button_to(parent_node: Node, gm: GameManager, pd: PlayerData) -> void:
	"""Add a cheat button to any parent node"""
	var cheat_btn = Button.new()
	cheat_btn.text = "CHEAT"
	cheat_btn.size = Vector2(80, 35)
	cheat_btn.position = Vector2(10, 10)
	cheat_btn.add_theme_color_override("font_color", Color.WHITE)
	cheat_btn.add_theme_color_override("font_color_hover", Color.CYAN)
	cheat_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	
	parent_node.add_child(cheat_btn)
	
	cheat_btn.pressed.connect(func():
		
		gm.add_credits(1000)
		gm.add_coins(100)
		pd.current_rerolls += 100
		
		
		# Force refresh the hangar UI elements directly
		_force_refresh_hangar_ui(parent_node)
		
	)
	

static func _force_refresh_hangar_ui(hangar_node: Node) -> void:
	"""Force refresh all UI elements in the hangar"""
	
	# Refresh store panel currency
	var store_panel = hangar_node.get_node_or_null("StoreSlotMachinePanel/StoreWrapper/StorePanel")
	if store_panel and store_panel.has_method("_update_ui"):
		store_panel._update_ui()
	
	# Refresh slot machine panel currency  
	var slot_panel = hangar_node.get_node_or_null("StoreSlotMachinePanel/SlotWrapper/SlotMachinePanel")
	if slot_panel and slot_panel.has_method("_update_ui"):
		slot_panel._update_ui()
	
	# Try the main hangar refresh method
	if hangar_node.has_method("_refresh_ui"):
		hangar_node._refresh_ui()
	
	# Manual fallback: find and update currency labels directly
	_update_currency_labels(hangar_node)

static func _update_currency_labels(hangar_node: Node) -> void:
	"""Manually update any currency labels we can find"""
	var gm = hangar_node.gm
	
	# Find store currency label
	var store_currency = hangar_node.get_node_or_null("StoreSlotMachinePanel/StoreWrapper/StorePanel/StoreCurrencyLabel")
	if store_currency:
		store_currency.text = "Credits: %d" % gm.credits
	
	# Find slot machine currency label
	var slot_currency = hangar_node.get_node_or_null("StoreSlotMachinePanel/SlotWrapper/SlotMachinePanel/SlotMachineCurrencyLabel")
	if slot_currency:
		slot_currency.text = "Coins: %d" % gm.coins
