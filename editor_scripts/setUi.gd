# LEVEL UI SETUP SCRIPT
# Save this as "setup_levelui.gd" and run it via Tools → Execute Script
# This script will:
# 1. Add all needed nodes for wave timer and blink UI
# 2. Swap health and shield bar positions
# 3. Reorganize the level label layout

@tool
extends EditorScript

func _run():
	print("=== SETTING UP LEVEL UI ===")
	
	# Load the LevelUI scene
	var scene_path = "res://scenes/game/LevelUI.tscn"
	var packed_scene = load(scene_path)
	if not packed_scene:
		print("❌ ERROR: Could not load LevelUI.tscn")
		return
	
	var root = packed_scene.instantiate()
	if not root:
		print("❌ ERROR: Could not instantiate LevelUI scene")
		return
	
	print("✅ Loaded LevelUI scene successfully")
	
	# Get existing nodes
	var bars_container = root.get_node("Bars")
	var existing_level_label = root.get_node("LevelLabel")
	
	if not bars_container:
		print("❌ ERROR: Could not find Bars container")
		root.queue_free()
		return
	
	print("📁 Found existing Bars container")
	
	# ===== STEP 1: SWAP HEALTH AND SHIELD BARS =====
	print("\n🔄 SWAPPING HEALTH AND SHIELD BAR POSITIONS...")
	_swap_health_shield_bars(bars_container)
	
	# ===== STEP 2: ADD BLINK UI UNDER HEALTH BARS =====
	print("\n➕ ADDING BLINK UI...")
	_add_blink_ui(bars_container)
	
	# ===== STEP 3: REORGANIZE LEVEL LABEL AND ADD WAVE TIMER =====
	print("\n🏷️ REORGANIZING LEVEL LAYOUT...")
	_reorganize_level_layout(root, existing_level_label)
	
	# ===== STEP 4: SAVE THE SCENE =====
	print("\n💾 SAVING SCENE...")
	var new_packed_scene = PackedScene.new()
	var pack_result = new_packed_scene.pack(root)
	if pack_result != OK:
		print("❌ ERROR: Could not pack scene")
		root.queue_free()
		return
	
	var save_result = ResourceSaver.save(new_packed_scene, scene_path)
	if save_result != OK:
		print("❌ ERROR: Could not save scene")
		root.queue_free()
		return
	
	root.queue_free()
	print("✅ SUCCESS: LevelUI.tscn has been updated!")
	print("\n🎯 CHANGES MADE:")
	print("   • Swapped Health and Shield bar positions")
	print("   • Added Blink count label and cooldown bar")
	print("   • Added Wave timer label and progress bar")
	print("   • Reorganized level label layout")
	print("\n📝 NEXT STEPS:")
	print("   • Update your LevelUI.gd script with the new code")
	print("   • Update Level.gd to connect wave manager")

func _swap_health_shield_bars(bars_container: Node) -> void:
	"""Swap the positions of health and shield bars"""
	var shield_container = bars_container.get_node("ShieldBarContainer")
	var hp_container = bars_container.get_node("HPBarContainer")
	
	if not shield_container or not hp_container:
		print("❌ ERROR: Could not find health/shield containers")
		return
	
	# Get their current indices
	var shield_index = shield_container.get_index()
	var hp_index = hp_container.get_index()
	
	print("   📊 Shield was at index: %d" % shield_index)
	print("   ❤️ Health was at index: %d" % hp_index)
	
	# Move health to where shield was, shield to where health was
	bars_container.move_child(hp_container, shield_index)
	bars_container.move_child(shield_container, hp_index)
	
	print("   ✅ Swapped: Health now first, Shield second")

func _add_blink_ui(bars_container: Node) -> void:
	"""Add blink UI components under the health bars"""
	
	# Create blink container
	var blink_container = VBoxContainer.new()
	blink_container.name = "BlinkContainer"
	bars_container.add_child(blink_container)
	blink_container.owner = bars_container.get_tree().edited_scene_root
	
	# Create blink count label
	var blink_count_label = Label.new()
	blink_count_label.name = "BlinkCountLabel"
	blink_count_label.text = "Blinks: 3/3"
	blink_count_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	blink_container.add_child(blink_count_label)
	blink_count_label.owner = bars_container.get_tree().edited_scene_root
	
	# Create blink cooldown bar
	var blink_cooldown_bar = ProgressBar.new()
	blink_cooldown_bar.name = "BlinkCooldownBar"
	blink_cooldown_bar.show_percentage = false
	blink_cooldown_bar.modulate = Color(0.8, 0.4, 1, 1)  # Purple color
	blink_cooldown_bar.value = 100.0  # Start full
	blink_cooldown_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	blink_container.add_child(blink_cooldown_bar)
	blink_cooldown_bar.owner = bars_container.get_tree().edited_scene_root
	
	print("   🎯 Added BlinkContainer with count label and cooldown bar")

func _reorganize_level_layout(root: Node, existing_level_label: Node) -> void:
	"""Reorganize level label and add wave timer components"""
	
	# Remove existing level label from its current position
	var old_parent = existing_level_label.get_parent()
	old_parent.remove_child(existing_level_label)
	
	# Create new level container (center-top)
	var level_container = VBoxContainer.new()
	level_container.name = "LevelContainer"
	
	# Set anchors for center-top positioning
	level_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	level_container.offset_left = -100.0
	level_container.offset_right = 100.0
	level_container.offset_top = 1.0
	level_container.offset_bottom = 80.0
	
	root.add_child(level_container)
	level_container.owner = root
	
	# Move existing level label into new container
	level_container.add_child(existing_level_label)
	existing_level_label.owner = root
	existing_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Create wave timer container
	var wave_timer_container = VBoxContainer.new()
	wave_timer_container.name = "WaveTimerContainer"
	level_container.add_child(wave_timer_container)
	wave_timer_container.owner = root
	
	# Create wave timer label
	var wave_timer_label = Label.new()
	wave_timer_label.name = "WaveTimerLabel"
	wave_timer_label.text = "Wave: 0:30"
	wave_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_timer_container.add_child(wave_timer_label)
	wave_timer_label.owner = root
	
	# Create wave timer bar
	var wave_timer_bar = ProgressBar.new()
	wave_timer_bar.name = "WaveTimerBar"
	wave_timer_bar.show_percentage = false
	wave_timer_bar.modulate = Color(1, 0.8, 0.2, 1)  # Orange/yellow color
	wave_timer_bar.value = 100.0  # Start full
	wave_timer_bar.custom_minimum_size = Vector2(200, 20)  # Make it wider
	wave_timer_container.add_child(wave_timer_bar)
	wave_timer_bar.owner = root
	
	print("   🏷️ Created LevelContainer with level label")
	print("   ⏱️ Added WaveTimerContainer with label and progress bar")

# Helper function to set control anchors (if needed)
func _set_control_anchors_preset(control: Control, preset: Control.LayoutPreset) -> void:
	"""Helper to set control anchor presets"""
	match preset:
		Control.PRESET_CENTER_TOP:
			control.anchor_left = 0.5
			control.anchor_right = 0.5
			control.anchor_top = 0.0
			control.anchor_bottom = 0.0
