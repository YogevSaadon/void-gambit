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
@onready var slot_machine_currency_label = $StoreSlotMachinePanel/SlotMachinePanel/SlotMachineCurrencyLabel

# ====== Managers ======
@onready var gm = get_tree().root.get_node("GameManager")
@onready var pem = get_tree().root.get_node("PassiveEffectManager")
@onready var pd = get_tree().root.get_node("PlayerData")

# ====== Built-in ======
func _ready() -> void:
	pd.current_rerolls = int(pd.get_stat("rerolls_per_wave"))
	player_stats_panel.initialize(pd)
	store_panel.initialize(gm, pd, pem, player_stats_panel)
	_connect_signals()
	_refresh_ui()
	_show_store()

# ====== UI ======
func _connect_signals() -> void:
	next_level_button.pressed.connect(_on_next_level_pressed)
	switch_button.pressed.connect(_on_switch_pressed)

func _refresh_ui() -> void:
	wave_label.text = "Level %d" % gm.level_number
	slot_machine_currency_label.text = "Gold Coins: %d" % gm.gold_coins
	player_stats_panel.update_stats()

# ====== Toggle Panels ======
func _show_store() -> void:
	store_panel.visible = true
	slot_machine_panel.visible = false
	switch_button.text = "Slot Machine"

func _show_slot_machine() -> void:
	store_panel.visible = false
	slot_machine_panel.visible = true
	switch_button.text = "Store"

# ====== Button Handlers ======
func _on_switch_pressed() -> void:
	if store_panel.visible:
		_show_slot_machine()
	else:
		_show_store()

func _on_next_level_pressed() -> void:
	gm.next_level()
	get_tree().change_scene_to_file("res://scenes/game/Level.tscn")
