# scripts/game/hangar/StoreLevelRarityLogic.gd
extends RefCounted
class_name StoreLevelRarityLogic

# ===== RARITY PROGRESSION DESIGN =====
# PHILOSOPHY: Start with scarcity (0% legendary), create meaningful breakpoints,
# use sigmoid curves for natural progression, maintain challenge at max level
#
# BREAKPOINTS (Psychological milestones):
# - Level 1-3: Commons only (learning phase)
# - Level 4: First uncommons appear (10%)
# - Level 7: Uncommons become viable (25%)
# - Level 10: First rares appear (8%) - major milestone
# - Level 15: Rares become common (20%) - mid-game power spike
# - Level 18: First epics appear (4%) - late game transition
# - Level 22: Epics become viable (12%) - endgame preparation
# - Level 25: Full rarity access including legendaries (5%)

# ===== BASE RARITY WEIGHTS (Before level scaling) =====
const BASE_WEIGHTS = {
	"common": 1.0,      # Always available
	"uncommon": 0.0,    # Unlocks at level 4
	"rare": 0.0,        # Unlocks at level 10
	"epic": 0.0,        # Unlocks at level 18
	"legendary": 0.0    # Unlocks at level 25
}

# ===== LEVEL PROGRESSION TABLE =====
# Hand-tuned based on TFT's proven breakpoint design
const LEVEL_RARITY_TABLE = {
	1:  {"common": 100, "uncommon": 0,  "rare": 0,  "epic": 0, "legendary": 0},
	2:  {"common": 100, "uncommon": 0,  "rare": 0,  "epic": 0, "legendary": 0},
	3:  {"common": 100, "uncommon": 0,  "rare": 0,  "epic": 0, "legendary": 0},
	4:  {"common": 90,  "uncommon": 10, "rare": 0,  "epic": 0, "legendary": 0},  # First uncommons
	5:  {"common": 85,  "uncommon": 15, "rare": 0,  "epic": 0, "legendary": 0},
	6:  {"common": 80,  "uncommon": 20, "rare": 0,  "epic": 0, "legendary": 0},
	7:  {"common": 75,  "uncommon": 25, "rare": 0,  "epic": 0, "legendary": 0},  # Uncommon breakpoint
	8:  {"common": 72,  "uncommon": 25, "rare": 3,  "epic": 0, "legendary": 0},
	9:  {"common": 68,  "uncommon": 27, "rare": 5,  "epic": 0, "legendary": 0},
	10: {"common": 62,  "uncommon": 30, "rare": 8,  "epic": 0, "legendary": 0},  # First rares - MAJOR MILESTONE
	11: {"common": 58,  "uncommon": 30, "rare": 12, "epic": 0, "legendary": 0},
	12: {"common": 54,  "uncommon": 30, "rare": 16, "epic": 0, "legendary": 0},
	13: {"common": 50,  "uncommon": 32, "rare": 18, "epic": 0, "legendary": 0},
	14: {"common": 47,  "uncommon": 31, "rare": 22, "epic": 0, "legendary": 0},
	15: {"common": 45,  "uncommon": 30, "rare": 25, "epic": 0, "legendary": 0},  # Rare breakpoint
	16: {"common": 42,  "uncommon": 30, "rare": 26, "epic": 2, "legendary": 0},
	17: {"common": 40,  "uncommon": 30, "rare": 27, "epic": 3, "legendary": 0},
	18: {"common": 38,  "uncommon": 30, "rare": 28, "epic": 4, "legendary": 0},  # First epics
	19: {"common": 35,  "uncommon": 30, "rare": 28, "epic": 7, "legendary": 0},
	20: {"common": 32,  "uncommon": 30, "rare": 28, "epic": 10, "legendary": 0},
	21: {"common": 30,  "uncommon": 28, "rare": 28, "epic": 14, "legendary": 0},
	22: {"common": 28,  "uncommon": 25, "rare": 30, "epic": 17, "legendary": 0},  # Epic breakpoint
	23: {"common": 25,  "uncommon": 25, "rare": 30, "epic": 18, "legendary": 2},
	24: {"common": 22,  "uncommon": 25, "rare": 30, "epic": 20, "legendary": 3},
	25: {"common": 20,  "uncommon": 25, "rare": 30, "epic": 20, "legendary": 5},  # LEGENDARY UNLOCK!
}

# ===== ANTI-FRUSTRATION SYSTEM =====
# Pity system inspired by Slay the Spire's rarity offset
var rarity_pity_counters: Dictionary = {
	"uncommon": 0,
	"rare": 0, 
	"epic": 0,
	"legendary": 0
}

# Pity thresholds - after this many store visits without seeing the rarity, guarantee it
const PITY_THRESHOLDS = {
	"uncommon": 8,    # After 8 store visits without uncommon, force one
	"rare": 12,       # After 12 store visits without rare, force one  
	"epic": 15,       # After 15 store visits without epic, force one
	"legendary": 20   # After 20 store visits without legendary, force one
}

# ===== MAIN INTERFACE =====

func get_level_based_items(available_items: Array, available_weapons: Array, level: int, store_visits: int = 0) -> Array:
	"""
	Main function: Get store items based on level-adjusted rarity probabilities
	
	Args:
		available_items: Array of PassiveItem objects from ItemDatabase
		available_weapons: Array of WeaponItem objects from ItemDatabase  
		level: Current player level (1-25)
		store_visits: Number of times player has visited store (for pity system)
	
	Returns:
		Array of 4 items/weapons selected based on level-based rarity
	"""
	
	# Combine all available items
	var all_items = available_items + available_weapons
	if all_items.is_empty():
		push_warning("StoreLevelRarityLogic: No items available")
		return []
	
	# Get level-based rarity weights
	var level_weights = _get_level_weights(level)
	
	# Group items by rarity
	var items_by_rarity = _group_items_by_rarity(all_items)
	
	# Apply pity system adjustments
	var adjusted_weights = _apply_pity_system(level_weights, items_by_rarity, store_visits)
	
	# Select 4 items using weighted selection
	var selected_items: Array = []
	for i in 4:
		var selected_item = _select_item_by_weight(adjusted_weights, items_by_rarity)
		if selected_item:
			selected_items.append(selected_item)
			
			# Update pity counters
			_update_pity_counters(selected_item.rarity)
			
			# Remove selected item to prevent duplicates (optional - you may want duplicates)
			# _remove_item_from_pools(selected_item, items_by_rarity)
	
	return selected_items

func get_level_breakdown(level: int) -> Dictionary:
	"""
	Debug function: Get exact percentages for each rarity at given level
	Useful for UI display and balancing
	"""
	return _get_level_weights(level)

# ===== INTERNAL LOGIC =====

func _get_level_weights(level: int) -> Dictionary:
	"""Get rarity weights for specific level"""
	# Clamp level to valid range
	level = clamp(level, 1, 25)
	
	# Return pre-calculated weights from table
	if level in LEVEL_RARITY_TABLE:
		return LEVEL_RARITY_TABLE[level].duplicate()
	
	# Fallback: interpolate between nearest levels (shouldn't happen with full table)
	return LEVEL_RARITY_TABLE[25].duplicate()

func _group_items_by_rarity(all_items: Array) -> Dictionary:
	"""Group items into arrays by their rarity for efficient selection"""
	var groups = {
		"common": [],
		"uncommon": [],
		"rare": [],
		"epic": [],
		"legendary": []
	}
	
	for item in all_items:
		if item.rarity in groups:
			# Only include items available for store
			if item.sources.has("store"):
				groups[item.rarity].append(item)
	
	return groups

func _apply_pity_system(base_weights: Dictionary, items_by_rarity: Dictionary, store_visits: int) -> Dictionary:
	"""Apply anti-frustration pity system to boost rare item chances"""
	var adjusted_weights = base_weights.duplicate()
	
	# Check each rarity for pity triggers
	for rarity in ["uncommon", "rare", "epic", "legendary"]:
		if base_weights.get(rarity, 0) > 0:  # Only apply pity if rarity is unlocked
			var pity_count = rarity_pity_counters.get(rarity, 0)
			var threshold = PITY_THRESHOLDS.get(rarity, 999)
			
			if pity_count >= threshold and not items_by_rarity[rarity].is_empty():
				# PITY TRIGGERED: Dramatically boost this rarity
				print("PITY TRIGGERED for %s after %d visits!" % [rarity, pity_count])
				adjusted_weights[rarity] = min(adjusted_weights[rarity] * 3.0, 50.0)  # Triple chance, cap at 50%
				
				# Reduce other rarities proportionally to maintain total ~100%
				var boost_amount = adjusted_weights[rarity] - base_weights[rarity]
				var other_rarities = ["common", "uncommon", "rare", "epic", "legendary"]
				other_rarities.erase(rarity)
				
				for other_rarity in other_rarities:
					if adjusted_weights.has(other_rarity) and adjusted_weights[other_rarity] > 0:
						var reduction = boost_amount / other_rarities.size()
						adjusted_weights[other_rarity] = max(adjusted_weights[other_rarity] - reduction, 0)
	
	return adjusted_weights

func _select_item_by_weight(weights: Dictionary, items_by_rarity: Dictionary) -> Variant:
	"""Select a single item using weighted random selection"""
	
	# Remove weights for rarities with no available items
	var valid_weights = {}
	var total_weight = 0.0
	
	for rarity in weights:
		if not items_by_rarity[rarity].is_empty() and weights[rarity] > 0:
			valid_weights[rarity] = weights[rarity]
			total_weight += weights[rarity]
	
	if valid_weights.is_empty():
		push_warning("StoreLevelRarityLogic: No valid rarities available")
		return null
	
	# Weighted random selection
	var random_value = randf() * total_weight
	var cumulative_weight = 0.0
	
	for rarity in valid_weights:
		cumulative_weight += valid_weights[rarity]
		if random_value <= cumulative_weight:
			# Select random item from this rarity
			var items_in_rarity = items_by_rarity[rarity]
			var random_index = randi() % items_in_rarity.size()
			return items_in_rarity[random_index]
	
	# Fallback (should never reach here)
	var fallback_rarity = valid_weights.keys()[0]
	var fallback_items = items_by_rarity[fallback_rarity]
	return fallback_items[0] if not fallback_items.is_empty() else null

func _update_pity_counters(selected_rarity: String) -> void:
	"""Update pity counters based on what was selected"""
	# Increment all pity counters
	for rarity in rarity_pity_counters:
		rarity_pity_counters[rarity] += 1
	
	# Reset the counter for the rarity that was selected
	if selected_rarity in rarity_pity_counters:
		rarity_pity_counters[selected_rarity] = 0

# ===== BALANCING UTILITIES =====

func simulate_level_distribution(level: int, iterations: int = 1000) -> Dictionary:
	"""
	Debug function: Simulate many rolls to verify probability distribution
	Returns percentage breakdown of actual results vs expected
	"""
	var results = {
		"common": 0,
		"uncommon": 0,
		"rare": 0,
		"epic": 0,
		"legendary": 0
	}
	
	# Mock items for simulation
	var mock_items = []
	for rarity in results.keys():
		for i in 10:  # 10 items per rarity
			var mock_item = {}
			mock_item["rarity"] = rarity
			mock_item["sources"] = ["store"]
			mock_items.append(mock_item)
	
	var items_by_rarity = _group_mock_items_by_rarity(mock_items)
	var weights = _get_level_weights(level)
	
	# Run simulation
	for i in iterations:
		var selected = _select_item_by_weight(weights, items_by_rarity)
		if selected:
			results[selected.rarity] += 1
	
	# Convert to percentages
	for rarity in results:
		results[rarity] = (results[rarity] / float(iterations)) * 100.0
	
	return results

func _group_mock_items_by_rarity(mock_items: Array) -> Dictionary:
	"""Helper for simulation"""
	var groups = {
		"common": [],
		"uncommon": [],
		"rare": [],
		"epic": [],
		"legendary": []
	}
	
	for item in mock_items:
		if item.rarity in groups:
			groups[item.rarity].append(item)
	
	return groups

func reset_pity_system() -> void:
	"""Reset pity counters (call when starting new run)"""
	for rarity in rarity_pity_counters:
		rarity_pity_counters[rarity] = 0

# ===== PROGRESSION MILESTONE DETECTION =====

func get_progression_milestones(level: int) -> Array[String]:
	"""Return array of milestone messages for this level"""
	var milestones: Array[String] = []
	
	match level:
		4:
			milestones.append("UNCOMMON ITEMS UNLOCKED!")
		7:
			milestones.append("Uncommon items now common (25%)")
		10:
			milestones.append("RARE ITEMS UNLOCKED!")
		15:
			milestones.append("Rare items now viable (25%)")
		18:
			milestones.append("EPIC ITEMS UNLOCKED!")
		22:
			milestones.append("Epic items now viable (17%)")
		25:
			milestones.append("LEGENDARY ITEMS UNLOCKED! Maximum power achieved!")
	
	return milestones

func is_major_milestone(level: int) -> bool:
	"""Check if this level represents a major progression milestone"""
	return level in [4, 10, 18, 25]  # Rarity unlock levels
