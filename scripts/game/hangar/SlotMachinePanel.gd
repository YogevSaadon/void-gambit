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
		print("SlotMachine: Not enough coins!")
		return
	
	# Deduct coin
	gm.spend_coins(1)
	print("SlotMachine: Spent 1 coin, remaining: %d" % gm.coins)
	
	# Get available items and weapons
	var owned_ids: Array = pd.passive_item_ids
	var available_items = item_db.get_slot_machine_items(owned_ids)
	var available_weapons = item_db.get_slot_machine_weapons()
	
	print("SlotMachine: Found %d items, %d weapons" % [available_items.size(), available_weapons.size()])
	
	# Combine items and weapons
	var all_available = available_items + available_weapons
	
	if all_available.is_empty():
		print("SlotMachine: No items or weapons available!")
		_update_ui()
		return
	
	print("SlotMachine: Total available: %d" % all_available.size())
	
	# ===== FIXED: USE LUCK-BASED SELECTION =====
	var player_luck = pd.get_stat("luck")
	print("SlotMachine: Player luck: %.1f" % player_luck)
	
	# Use the luck system you built!
	var random_result = slot_logic.get_luck_based_item(all_available, player_luck)
	
	# Fallback to random if luck system fails
	if not random_result:
		print("SlotMachine: Luck system failed, using fallback")
		random_result = all_available[randi() % all_available.size()]
	
	print("SlotMachine: Selected: %s (rarity: %s)" % [random_result.name, random_result.rarity])
	
	if random_result:
		# Show result
		slot_result_item.set_item_or_weapon(random_result)
		slot_result_item.visible = true
		
		# Add to inventory
		if random_result is PassiveItem:
			pd.add_item(random_result)
			pem.initialize_from_player_data(pd)
			print("Slot machine gave ITEM: %s" % random_result.name)
		elif random_result is WeaponItem:
			var success = pd.add_weapon(random_result)
			if not success:
				print("Slot machine gave weapon but all slots full: %s" % random_result.name)
			else:
				print("Slot machine gave WEAPON: %s" % random_result.name)
		else:
			print("SlotMachine: Unknown result type: %s" % random_result)
	
	# Update UI
	_update_ui()
	
	# Update stats panel
	if stat_panel:
		stat_panel.update_stats()
