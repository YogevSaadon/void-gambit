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
	update_stats()

func _setup_scroll_container() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	custom_minimum_size = Vector2(200, 300)

func update_stats() -> void:
	if not pd:
		return
	
	# Clear existing labels
	for child in stats_container.get_children():
		child.queue_free()
	
	# Wait one frame for children to be freed
	await get_tree().process_frame
	
	# Get current stat set
	var current_stats = main_stats if showing_main_stats else secondary_stats
	
	# Create and populate labels
	for stat_def in current_stats:
		var label = Label.new()
		label.custom_minimum_size = Vector2(180, 25)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Get stat value
		var value = pd.get_stat(stat_def.stat)
		
		# Apply multiplier if specified (for percentages)
		if stat_def.has("multiply"):
			value *= stat_def.multiply
		
		# Format and set text
		var formatted_value = stat_def.format % value
		label.text = stat_def.label + ": " + formatted_value
		
		stats_container.add_child(label)

func toggle_stats_view() -> void:
	showing_main_stats = !showing_main_stats
	update_stats()

func get_current_view_name() -> String:
	return "Advanced" if showing_main_stats else "Main"
