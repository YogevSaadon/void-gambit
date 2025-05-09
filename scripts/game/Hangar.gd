extends Node
class_name Hangar

# ====== UI Elements ======
@onready var next_level_button = $NextLevelButton
@onready var top_bar = $TopBar
@onready var wave_label = $TopBar/WaveLabel
@onready var switch_button = $TopBar/SwitchButton

@onready var left_panel = $LeftPanel
@onready var player_stats_panel = $LeftPanel/PlayerStatsPanel
@onready var weapon_slots_panel = $LeftPanel/WeaponSlotsPanel
@onready var inventory_scroll = $LeftPanel/InventoryScroll
@onready var inventory_grid = $LeftPanel/InventoryScroll/InventoryGrid

@onready var center_panel = $StoreSlotMachinePanel
@onready var store_panel = $StoreSlotMachinePanel/StorePanel
@onready var slot_machine_panel = $StoreSlotMachinePanel/SlotMachinePanel

@onready var store_currency_label = $StoreSlotMachinePanel/StorePanel/StoreCurrencyLabel
@onready var reroll_button = $StoreSlotMachinePanel/StorePanel/RerollButton
@onready var store_items = [
	$StoreSlotMachinePanel/StorePanel/StoreItem0,
	$StoreSlotMachinePanel/StorePanel/StoreItem1,
	$StoreSlotMachinePanel/StorePanel/StoreItem2,
	$StoreSlotMachinePanel/StorePanel/StoreItem3
]

@onready var slot_machine_currency_label = $StoreSlotMachinePanel/SlotMachinePanel/SlotMachineCurrencyLabel

# ====== Managers ======
@onready var gm = get_tree().root.get_node("GameManager")
@onready var pem = get_tree().root.get_node("PassiveEffectManager")
@onready var pd = get_tree().root.get_node("PlayerData")

# ====== Built-in Methods ======
func _ready() -> void:
	pd.current_rerolls = pd.player_stats.get("rerolls_per_wave", 1)
	_connect_signals()
	_refresh_ui()

# ====== UI Management ======
func _connect_signals() -> void:
	next_level_button.pressed.connect(_on_next_level_pressed)
	switch_button.pressed.connect(_on_switch_pressed)
	reroll_button.pressed.connect(_on_reroll_pressed)
	for store_button in store_items:
		store_button.pressed.connect(_on_store_item_pressed.bind(store_button))

func _refresh_ui() -> void:
	var stats = pd.player_stats

	wave_label.text = "Level %d" % gm.level_number

	player_stats_panel.get_node("HealthLabel").text = "HP: %d/%d" % [
		stats.get("hp", 0),
		stats.get("max_hp", 0)
	]

	player_stats_panel.get_node("ShieldLabel").text = "Shield: %d/%d" % [
		stats.get("shield", 0),
		stats.get("max_shield", 0)
	]

	player_stats_panel.get_node("BlinksLabel").text = "Blinks: %d" % stats.get("blinks", 0)

	store_currency_label.text = "Credits: %d" % gm.coins
	reroll_button.text = "Reroll (%d)" % pd.current_rerolls
	reroll_button.disabled = pd.current_rerolls <= 0

	slot_machine_currency_label.text = "Gold Coins: %d" % gm.gold_coins

	_show_store()
	_populate_store()

func _populate_store() -> void:
	var owned_items = pd.passive_item_names
	var all_items = PassiveItem.get_all_items().filter(func(item):
		return not item.is_unique or not owned_items.has(item.name)
)
	all_items.shuffle()


	for i in range(store_items.size()):
		if i < all_items.size():
			var item = all_items[i]
			var store_slot = store_items[i]

			if store_slot.has_method("set_item"):
				store_slot.set_item(item)
				store_slot.visible = true
		else:
			store_items[i].visible = false

func _show_store() -> void:
	store_panel.visible = true
	slot_machine_panel.visible = false
	switch_button.text = "Slot Machine"

func _show_slot_machine() -> void:
	store_panel.visible = false
	slot_machine_panel.visible = true
	switch_button.text = "Store"

# ====== Buttons Actions ======
func _on_switch_pressed() -> void:
	if store_panel.visible:
		_show_slot_machine()
	else:
		_show_store()

func _on_reroll_pressed() -> void:
	if pd.current_rerolls > 0:
		pd.current_rerolls -= 1
		_refresh_ui()

func _on_next_level_pressed() -> void:
	gm.next_level()
	get_tree().change_scene_to_file("res://scenes/game/Level.tscn")

func _on_store_item_pressed(button: Button) -> void:
	if not button is StoreItem:
		return

	if button.purchase_item(pd, gm, pem):
		_refresh_ui()
