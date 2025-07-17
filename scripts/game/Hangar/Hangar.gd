# scripts/game/Hangar/Hangar.gd
extends Node
class_name Hangar

# ====== UI Elements ======
@onready var next_level_button = $NextLevelButton
@onready var top_bar = $TopBar
@onready var wave_label = $TopBar/WaveLabel
@onready var switch_button = $TopBar/SwitchButton

@onready var left_panel = $LeftPanel
@onready var player_stats_panel = $LeftPanel/PlayerStatsPanel
@onready var toggle_stats_button = $LeftPanel/Button  # ← Fixed path for your Button node
@onready var weapon_slots_panel = $LeftPanel/WeaponSlotsPanel
@onready var inventory_scroll = $LeftPanel/InventoryScroll
@onready var inventory_grid = $LeftPanel/InventoryScroll/InventoryGrid

@onready var center_panel = $StoreSlotMachinePanel

# ===== CHANGED: Update paths to include wrappers =====
@onready var store_panel = $StoreSlotMachinePanel/StoreWrapper/StorePanel
@onready var slot_machine_panel = $StoreSlotMachinePanel/SlotWrapper/SlotMachinePanel

# ===== NEW: Add wrapper references =====
@onready var store_wrapper = $StoreSlotMachinePanel/StoreWrapper
@onready var slot_wrapper = $StoreSlotMachinePanel/SlotWrapper

# ====== Managers ======
@onready var gm = get_tree().root.get_node("GameManager")
@onready var pem = get_tree().root.get_node("PassiveEffectManager")
@onready var pd = get_tree().root.get_node("PlayerData")

# ====== Built-in ======
func _ready() -> void:
	pd.current_rerolls = int(pd.get_stat("rerolls_per_wave")) 
	player_stats_panel.initialize(pd)
	store_panel.initialize(gm, pd, pem, player_stats_panel)
	slot_machine_panel.initialize(gm, pd, pem, player_stats_panel)
	_connect_signals()
	_refresh_ui()
	_show_store()

# ====== UI ======
func _connect_signals() -> void:
	next_level_button.pressed.connect(_on_next_level_pressed)
	switch_button.pressed.connect(_on_switch_pressed)
	
	# Connect the toggle stats button
	toggle_stats_button.pressed.connect(_on_toggle_stats_pressed)
	toggle_stats_button.text = "Advanced"  # Set initial text

func _refresh_ui() -> void:
	wave_label.text = "Level %d" % gm.level_number
	player_stats_panel.update_stats()

# ===== CHANGED: Toggle Wrappers instead of Panels =====
func _show_store() -> void:
	store_wrapper.visible = true      # Changed from store_panel.visible = true
	slot_wrapper.visible = false      # Changed from slot_machine_panel.visible = false
	switch_button.text = "Slot Machine"

func _show_slot_machine() -> void:
	store_wrapper.visible = false     # Changed from store_panel.visible = false
	slot_wrapper.visible = true       # Changed from slot_machine_panel.visible = true
	switch_button.text = "Store"

# ====== Button Handlers ======
func _on_switch_pressed() -> void:
	if store_wrapper.visible:         # Changed from store_panel.visible
		_show_slot_machine()
	else:
		_show_store()

func _on_next_level_pressed() -> void:
	gm.next_level()
	get_tree().change_scene_to_file("res://scenes/game/Level.tscn")

# ====== NEW: Toggle Stats Handler ======
func _on_toggle_stats_pressed() -> void:
	player_stats_panel.toggle_stats_view()
	toggle_stats_button.text = player_stats_panel.get_current_view_name()
