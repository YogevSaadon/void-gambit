extends Node
class_name SlotMachinePanel

@onready var slot_currency_label = $SlotMachineCurrencyLabel
@onready var spin_button = $SpinButton
@onready var slot_result_item = $SlotResultItem

@onready var item_db = get_tree().root.get_node("ItemDatabase")
@onready var slot_logic = SlotMachineLogic.new()

var gm: GameManager
var pd: PlayerData
var pem: PassiveEffectManager
var stat_panel: Node

func initialize(game_manager: GameManager, player_data: PlayerData, passive_mgr: PassiveEffectManager, stats_panel: Node) -> void:
	gm = game_manager
	pd = player_data
	pem = passive_mgr
	stat_panel = stats_panel
	
	_setup_ui()
	_connect_signals()
	_update_ui()

func _setup_ui() -> void:
	spin_button.text = "SPIN (1 Coin)"
	slot_result_item.visible = false

func _connect_signals() -> void:
	spin_button.pressed.connect(_on_spin_pressed)

func _update_ui() -> void:
	slot_currency_label.text = "Coins: %d" % gm.coins
	spin_button.disabled = gm.coins <= 0

func _on_spin_pressed() -> void:
	if gm.coins <= 0:
		return
	
	# Deduct coin
	gm.spend_coins(1)
	
	# Get random item
	var owned_ids: Array = pd.passive_item_ids
	var available_items = item_db.get_slot_machine_items(owned_ids)
	var random_item = slot_logic.get_random_item(available_items)
	
	if random_item:
		# Show result
		slot_result_item.set_item(random_item)
		slot_result_item.visible = true
		
		# Add to inventory
		pd.add_item(random_item)
		pem.initialize_from_player_data(pd)
		
		print("Slot machine gave: %s" % random_item.name)
	
	# Update UI (this will refresh coin count and button state)
	_update_ui()
	
	# Update stats panel like the store does
	if stat_panel:
		stat_panel.update_stats()
