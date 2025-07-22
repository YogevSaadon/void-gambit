# scripts/game/hangar/StorePanel.gd - AUTO-REROLL AFTER PURCHASE
extends Node
class_name StorePanel

# UI Elements
@onready var store_currency_label = $StoreCurrencyLabel
@onready var reroll_button        = $RerollButton
@onready var store_items          = [
	$StoreItem0,
	$StoreItem1,
	$StoreItem2,
	$StoreItem3
]

# Dependencies
@onready var item_db = get_tree().root.get_node("ItemDatabase")

# Manager references
var gm          : GameManager
var pd          : PlayerData
var pem         : PassiveEffectManager
var stat_panel  : Node

# Level-based rarity system
var rarity_system: StoreLevelRarityLogic = StoreLevelRarityLogic.new()
var store_visit_count: int = 0

# Initialization
func initialize(game_manager: GameManager,
				player_data:   PlayerData,
				passive_mgr:   PassiveEffectManager,
				stats_panel:   Node) -> void:
	gm         = game_manager
	pd         = player_data
	pem        = passive_mgr
	stat_panel = stats_panel
	
	# Reset rarity system for new run
	rarity_system.reset_pity_system()
	store_visit_count = 0
	
	_connect_signals()
	_update_ui()
	_populate_items()

# Signal connections
func _connect_signals() -> void:
	reroll_button.pressed.connect(_on_reroll_pressed)
	for btn in store_items:
		btn.pressed.connect(_on_store_item_pressed.bind(btn))

# UI updates
func _update_ui() -> void:
	store_currency_label.text = "Credits: %d" % gm.credits
	reroll_button.text        = "Reroll (%d)" % pd.current_rerolls
	reroll_button.disabled    = pd.current_rerolls <= 0

# Level-based item population
func _populate_items() -> void:
	store_visit_count += 1
	
	# Get available items using existing logic
	var owned_ids: Array = pd.passive_item_ids
	var available_items = item_db.get_store_items(owned_ids)
	var available_weapons = item_db.get_store_weapons()
	
	# Use level-based rarity selection
	var current_level = gm.level_number
	var selected_items = rarity_system.get_level_based_items(
		available_items, 
		available_weapons, 
		current_level,
		store_visit_count
	)
	
	# Show progression milestones
	_show_progression_milestones(current_level)
	
	# Populate store slots
	for i in range(store_items.size()):
		if i < selected_items.size():
			store_items[i].set_item_or_weapon(selected_items[i])
			store_items[i].visible = true
			store_items[i].disabled = false
			_apply_rarity_styling(store_items[i], selected_items[i])
		else:
			store_items[i].visible = false

# Progression milestone notifications
func _show_progression_milestones(level: int) -> void:
	var milestones = rarity_system.get_progression_milestones(level)
	for milestone in milestones:
		pass # Removed debug print

# Visual rarity styling
func _apply_rarity_styling(button: StoreItem, item) -> void:
	var base_color = item.get_rarity_color()
	button.add_theme_color_override("font_color", base_color)
	
	match item.rarity:
		"epic":
			_add_glow_effect(button, Color(0.6, 0, 1, 0.3))
		"legendary":
			_add_glow_effect(button, Color(1, 0.8, 0, 0.5))
			_add_pulse_animation(button)

# Visual effects
func _add_glow_effect(button: Button, glow_color: Color) -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(_set_button_modulate.bind(button), glow_color, Color.WHITE, 1.0)
	tween.tween_method(_set_button_modulate.bind(button), Color.WHITE, glow_color, 1.0)

func _add_pulse_animation(button: Button) -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.8)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.8)

func _set_button_modulate(button: Button, color: Color) -> void:
	if is_instance_valid(button):
		button.modulate = color

# Button event handlers
func _on_reroll_pressed() -> void:
	if pd.current_rerolls > 0:
		pd.current_rerolls -= 1
		store_visit_count += 1
		
		for slot in store_items:
			slot.disabled = false
		_update_ui()
		_populate_items()

# ===== UPDATED: Auto-reroll after purchase =====
func _on_store_item_pressed(button: Button) -> void:
	if not button is StoreItem:
		return
	
	if button.purchase_item(pd, gm, pem):
		# Update UI and stats first
		_update_ui()
		stat_panel.update_stats()
		
		# Hide all items after purchase
		for slot in store_items:
			slot.visible = false
		
		# AUTO-REROLL: Try to reroll if player has rerolls available
		if pd.current_rerolls > 0:
			print("Auto-rerolling after purchase...")
			
			# Use a brief delay for better UX (let player see what they bought)
			await get_tree().create_timer(0.3).timeout
			
			# Trigger reroll
			pd.current_rerolls -= 1
			store_visit_count += 1
			
			# Re-enable all slots and refresh store
			for slot in store_items:
				slot.disabled = false
			
			_update_ui()
			_populate_items()
		else:
			print("No rerolls available for auto-reroll")

# ===== HELPER: Manual reroll function for other uses =====
func try_auto_reroll() -> bool:
	"""Try to perform an auto-reroll. Returns true if successful."""
	if pd.current_rerolls > 0:
		pd.current_rerolls -= 1
		store_visit_count += 1
		
		for slot in store_items:
			slot.disabled = false
		_update_ui()
		_populate_items()
		return true
	
	return false
