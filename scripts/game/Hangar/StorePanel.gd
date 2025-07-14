extends Node
class_name StorePanel

@onready var store_currency_label = $StoreCurrencyLabel
@onready var reroll_button        = $RerollButton
@onready var store_items          = [
	$StoreItem0,
	$StoreItem1,
	$StoreItem2,
	$StoreItem3
]

@onready var item_db = get_tree().root.get_node("ItemDatabase")

var gm          : GameManager
var pd          : PlayerData
var pem         : PassiveEffectManager
var stat_panel  : Node

func initialize(game_manager: GameManager,
				player_data:   PlayerData,
				passive_mgr:   PassiveEffectManager,
				stats_panel:   Node) -> void:
	gm         = game_manager
	pd         = player_data
	pem        = passive_mgr
	stat_panel = stats_panel
	_connect_signals()
	_update_ui()
	_populate_items()

func _connect_signals() -> void:
	reroll_button.pressed.connect(_on_reroll_pressed)
	for btn in store_items:
		btn.pressed.connect(_on_store_item_pressed.bind(btn))

func _update_ui() -> void:
	store_currency_label.text = "Credits: %d" % gm.credits
	reroll_button.text        = "Reroll (%d)" % pd.current_rerolls
	reroll_button.disabled    = pd.current_rerolls <= 0

func _populate_items() -> void:
	var owned_ids: Array = pd.passive_item_ids
	var available_items = item_db.get_store_items(owned_ids)
	available_items.shuffle()
	
	for i in range(store_items.size()):
		if i < available_items.size():
			store_items[i].set_item(available_items[i])
			store_items[i].visible = true
			store_items[i].disabled = false
		else:
			store_items[i].visible = false

func _on_reroll_pressed() -> void:
	if pd.current_rerolls > 0:
		pd.current_rerolls -= 1
		for slot in store_items:
			slot.disabled = false
		_update_ui()
		_populate_items()

func _on_store_item_pressed(button: Button) -> void:
	if not button is StoreItem:
		return
	if button.purchase_item(pd, gm, pem):
		_update_ui()
		stat_panel.update_stats()
		for slot in store_items:
			if slot != button:
				slot.visible = false
