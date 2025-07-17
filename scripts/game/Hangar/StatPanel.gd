extends ScrollContainer
class_name StatPanel

@onready var stats_container = $StatsContainer

var pd: PlayerData = null
var showing_main_stats: bool = true

# MAIN STATS - Core combat stats
var main_stats = [
	{"stat": "max_hp", "label": "HP", "format": "%d"},
	{"stat": "max_shield", "label": "Shield", "format": "%d"},
	{"stat": "blinks", "label": "Blinks", "format": "%d"},
	{"stat": "speed", "label": "Speed", "format": "%.0f"},
	{"stat": "weapon_range", "label": "Range", "format": "%.0f"},
	{"stat": "crit_chance", "label": "Crit", "format": "%.1f%%", "multiply": 100},
	{"stat": "crit_damage", "label": "Crit Dmg", "format": "%.1fx"},
	{"stat": "damage_percent", "label": "Damage", "format": "%.1f%%", "multiply": 100},
	{"stat": "armor", "label": "Armor", "format": "%.0f"},
	{"stat": "shield_recharge_rate", "label": "Shield Regen", "format": "%.1f"},
	{"stat": "blink_cooldown", "label": "Blink CD", "format": "%.1fs"},
]

# SECONDARY STATS - Economy, weapon-specific, niche stats
var secondary_stats = [
	{"stat": "luck", "label": "Luck", "format": "%.0f"},
	{"stat": "golden_ship_count", "label": "Golden Ships", "format": "%d"},
	{"stat": "rerolls_per_wave", "label": "Free Rerolls", "format": "%d"},
	{"stat": "ship_count", "label": "Ship Count", "format": "%d"},
	{"stat": "ship_damage_percent", "label": "Ship Damage", "format": "%.1f%%", "multiply": 100},
	{"stat": "bullet_damage_percent", "label": "Bullet Damage", "format": "%.1f%%", "multiply": 100},
	{"stat": "laser_damage_percent", "label": "Laser Damage", "format": "%.1f%%", "multiply": 100},
	{"stat": "explosive_damage_percent", "label": "Explosive Damage", "format": "%.1f%%", "multiply": 100},
	{"stat": "bio_damage_percent", "label": "Bio Damage", "format": "%.1f%%", "multiply": 100},
	{"stat": "laser_reflects", "label": "Laser Reflects", "format": "%d"},
	{"stat": "bullet_attack_speed", "label": "Bullet Speed", "format": "%.1fx"},
	{"stat": "bio_spread_chance", "label": "Bio Spread", "format": "%.1f%%", "multiply": 100},
	{"stat": "explosion_radius_bonus", "label": "Explosion Size", "format": "%.1f%%", "multiply": 100},
]

func initialize(player_data: PlayerData) -> void:
	pd = player_data
	_setup_scroll_container()
	_create_stat_labels()
	update_stats()

func _setup_scroll_container() -> void:
	"""Configure ScrollContainer for vertical scrolling"""
	# GODOT 4 CORRECT SYNTAX:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	
	# Set container size and behavior
	custom_minimum_size = Vector2(200, 300)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Configure the VBoxContainer
	if stats_container:
		stats_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stats_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		stats_container.custom_minimum_size = Vector2(180, 0)  # Width but flexible height

func _create_stat_labels() -> void:
	print("Creating stat labels...")
	
	# Clear any existing labels
	for child in stats_container.get_children():
		child.queue_free()
	
	# Get current stat set
	var current_stats = main_stats if showing_main_stats else secondary_stats
	print("Creating %d labels for %s stats" % [current_stats.size(), "main" if showing_main_stats else "secondary"])
	
	# Create labels for each stat
	for i in range(current_stats.size()):
		var stat_def = current_stats[i]
		var label = Label.new()
		label.name = stat_def.stat + "_label"
		label.text = stat_def.label + ": Loading..."  # Temporary text to see if label exists
		label.add_theme_color_override("font_color", Color.WHITE)
		
		# Force proper sizing for vertical layout
		label.custom_minimum_size = Vector2(180, 25)  # Fixed width, minimum height
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		stats_container.add_child(label)
		print("Created label %d: %s" % [i, label.text])
	
	# Force the container to recalculate its size
	stats_container.queue_redraw()
	
	print("Finished creating labels. Container has %d children" % stats_container.get_child_count())

func update_stats() -> void:
	if pd == null:
		print("PlayerData is null, cannot update stats")
		return
	
	print("Updating stats...")
	
	# Get current stat set
	var current_stats = main_stats if showing_main_stats else secondary_stats
	
	# Update each stat label
	for i in range(current_stats.size()):
		if i >= stats_container.get_child_count():
			print("Not enough labels created! Need %d, have %d" % [current_stats.size(), stats_container.get_child_count()])
			break
			
		var stat_def = current_stats[i]
		var label = stats_container.get_child(i) as Label
		
		if label:
			var value = pd.get_stat(stat_def.stat)
			
			# Apply multiplier if specified (for percentages)
			if stat_def.has("multiply"):
				value *= stat_def.multiply
			
			# Format the text
			var formatted_value = stat_def.format % value
			label.text = stat_def.label + ": " + formatted_value
			print("Updated label %d: %s" % [i, label.text])
		else:
			print("Label %d is null!" % i)
	
	print("Stats update complete")

func toggle_stats_view() -> void:
	"""Switch between main and secondary stats"""
	print("Toggling stats view from %s to %s" % ["main" if showing_main_stats else "secondary", "secondary" if showing_main_stats else "main"])
	showing_main_stats = !showing_main_stats
	_create_stat_labels()
	update_stats()

func get_current_view_name() -> String:
	"""Get current view name for button text"""
	return "Advanced" if showing_main_stats else "Main"
