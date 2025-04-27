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

@onready var gm = get_tree().root.get_node("GameManager")

# ====== Built-in Methods ======

func _ready() -> void:
	_connect_signals()
	_refresh_ui()

# ====== UI Management ======

func _connect_signals() -> void:
	next_level_button.pressed.connect(_on_next_level_pressed)
	switch_button.pressed.connect(_on_switch_pressed)
	reroll_button.pressed.connect(_on_reroll_pressed)

func _refresh_ui() -> void:
	# Update wave info
	wave_label.text = "Level %d" % gm.level_number

	# Player Stats Panel
	player_stats_panel.get_node("HealthLabel").text = "HP: %d/%d" % [gm.player_stats["hp"], gm.player_stats["max_hp"]]
	player_stats_panel.get_node("ShieldLabel").text = "Shield: %d/%d" % [gm.player_stats["shield"], gm.player_stats["max_shield"]]
	player_stats_panel.get_node("BlinksLabel").text = "Blinks: %d" % gm.player_stats["blinks"]

	# Store
	store_currency_label.text = "Credits: %d" % gm.coins
	reroll_button.text = "Reroll (%d)" % gm.player_stats["rerolls"]

	# Slot Machine
	slot_machine_currency_label.text = "Gold Coins: %d" % gm.gold_coins

	# Default to showing Store
	_show_store()

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
	if gm.player_stats["rerolls"] > 0:
		gm.player_stats["rerolls"] -= 1
		_refresh_ui()
		print("Store rerolled!")

func _on_next_level_pressed() -> void:
	gm.next_level()
	get_tree().change_scene_to_file("res://scenes/game/Level.tscn")
