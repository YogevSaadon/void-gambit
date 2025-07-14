# SLOT MACHINE LOGIC - LUCK-BASED RARITY SYSTEM
# ===============================================
# 
# CORE ALGORITHM:
# 1. Takes player's luck stat as input
# 2. Uses diminishing returns formula: luck_factor = luck / (luck + scaling_constant)
# 3. Redistributes probability from common items to higher rarities
# 4. Selects rarity based on modified weights
# 5. Returns random item from selected rarity pool
#
# MATHEMATICAL APPROACH:
# - Base probabilities: 60% common, 25% uncommon, 10% rare, 4% epic, 1% legendary
# - Luck "steals" probability from commons and redistributes upward
# - Maximum effect caps at ~50% common reduction to maintain some randomness
# - Scaling constant (50.0) controls how fast luck improvement feels
#
# BALANCING PARAMETERS:
# - Change SCALING_CONSTANT for luck feel (lower = faster scaling)
# - Change MAX_COMMON_REDUCTION for luck power (higher = more dramatic)
# - Change redistribution percentages for rarity preference
#
# USAGE:
# var slot_logic = SlotMachineLogic.new()
# var item = slot_logic.get_luck_based_item(available_items, player_luck_stat)

extends RefCounted
class_name SlotMachineLogic

# ===== BALANCING PARAMETERS =====
# Adjust these during playtesting to tune luck effectiveness

const SCALING_CONSTANT: float = 50.0        # Lower = luck feels more impactful early
const MAX_COMMON_REDUCTION: float = 0.5     # Maximum reduction of common probability (0.5 = 50%)

# Base rarity probabilities (must sum to 1.0)
const BASE_WEIGHTS = {
	"common": 0.60,      # 60%
	"uncommon": 0.25,    # 25% 
	"rare": 0.10,        # 10%
	"epic": 0.04,        # 4%
	"legendary": 0.01    # 1%
}

# How stolen probability is redistributed to higher rarities
const REDISTRIBUTION_RATES = {
	"uncommon": 0.40,    # 40% of stolen probability
	"rare": 0.30,        # 30% of stolen probability  
	"epic": 0.20,        # 20% of stolen probability
	"legendary": 0.10    # 10% of stolen probability
}

# ===== MAIN INTERFACE =====

func get_luck_based_item(available_items: Array, luck: float) -> PassiveItem:
	"""
	Main function: Get an item based on luck-modified rarity probabilities
	
	Args:
		available_items: Array of PassiveItem objects available for slot machine
		luck: Player's current luck stat value
	
	Returns:
		PassiveItem selected based on luck-modified probabilities
	"""
	if available_items.is_empty():
		push_warning("SlotMachineLogic: No items available")
		return null
	
	# Step 1: Calculate luck-modified rarity weights
	var modified_weights = _calculate_luck_modified_weights(luck)
	
	# Step 2: Filter items by availability and group by rarity
	var items_by_rarity = _group_items_by_rarity(available_items)
	
	# Step 3: Select a rarity based on modified probabilities
	var selected_rarity = _select_rarity_by_weight(modified_weights, items_by_rarity)
	
	# Step 4: Return random item from selected rarity
	return _get_random_item_from_rarity(items_by_rarity, selected_rarity)

# ===== FALLBACK FOR COMPATIBILITY =====

func get_random_item(available_items: Array) -> PassiveItem:
	"""
	Fallback function for compatibility - uses 0 luck (base probabilities)
	"""
	return get_luck_based_item(available_items, 0.0)

# ===== INTERNAL LOGIC =====

func _calculate_luck_modified_weights(luck: float) -> Dictionary:
	"""
	Apply luck scaling to base rarity weights using diminishing returns formula
	"""
	# Calculate luck factor with diminishing returns (approaches 1.0 but never reaches it)
	var luck_factor = luck / (luck + SCALING_CONSTANT)
	
	# Calculate how much probability to steal from commons
	var stolen_from_common = BASE_WEIGHTS["common"] * luck_factor * MAX_COMMON_REDUCTION
	
	# Build modified weights
	var modified = {
		"common": BASE_WEIGHTS["common"] - stolen_from_common,
		"uncommon": BASE_WEIGHTS["uncommon"] + stolen_from_common * REDISTRIBUTION_RATES["uncommon"],
		"rare": BASE_WEIGHTS["rare"] + stolen_from_common * REDISTRIBUTION_RATES["rare"], 
		"epic": BASE_WEIGHTS["epic"] + stolen_from_common * REDISTRIBUTION_RATES["epic"],
		"legendary": BASE_WEIGHTS["legendary"] + stolen_from_common * REDISTRIBUTION_RATES["legendary"]
	}
	
	return modified

func _group_items_by_rarity(available_items: Array) -> Dictionary:
	"""
	Group items into arrays by their rarity for efficient selection
	"""
	var groups = {
		"common": [],
		"uncommon": [],
		"rare": [],
		"epic": [],
		"legendary": []
	}
	
	for item in available_items:
		if item is PassiveItem and item.rarity in groups:
			# Only include items available for slot machine
			if "slot_machine" in item.sources:
				groups[item.rarity].append(item)
	
	return groups

func _select_rarity_by_weight(weights: Dictionary, items_by_rarity: Dictionary) -> String:
	"""
	Select a rarity based on weighted probabilities, skipping empty rarities
	"""
	# Remove weights for rarities with no available items
	var valid_weights = {}
	var total_weight = 0.0
	
	for rarity in weights:
		if not items_by_rarity[rarity].is_empty():
			valid_weights[rarity] = weights[rarity]
			total_weight += weights[rarity]
	
	if valid_weights.is_empty():
		push_warning("SlotMachineLogic: No items available for any rarity")
		return "common"  # Fallback
	
	# Normalize weights to ensure they sum to 1.0
	for rarity in valid_weights:
		valid_weights[rarity] /= total_weight
	
	# Select rarity using weighted random selection
	var random_value = randf()
	var cumulative_weight = 0.0
	
	for rarity in valid_weights:
		cumulative_weight += valid_weights[rarity]
		if random_value <= cumulative_weight:
			return rarity
	
	# Fallback (should never reach here)
	return valid_weights.keys()[0]

func _get_random_item_from_rarity(items_by_rarity: Dictionary, rarity: String) -> PassiveItem:
	"""
	Get a random item from the specified rarity group
	"""
	var items_in_rarity = items_by_rarity[rarity]
	
	if items_in_rarity.is_empty():
		push_warning("SlotMachineLogic: No items in selected rarity: " + rarity)
		# Try to find any available item as fallback
		for fallback_rarity in items_by_rarity:
			if not items_by_rarity[fallback_rarity].is_empty():
				items_in_rarity = items_by_rarity[fallback_rarity]
				break
	
	if items_in_rarity.is_empty():
		return null
	
	var random_index = randi() % items_in_rarity.size()
	return items_in_rarity[random_index]

# ===== DEBUG AND TESTING =====

func get_probability_breakdown(luck: float) -> Dictionary:
	"""
	Debug function: Returns the exact probabilities for each rarity at given luck
	Useful for balancing and testing
	"""
	return _calculate_luck_modified_weights(luck)

func simulate_results(available_items: Array, luck: float, iterations: int = 1000) -> Dictionary:
	"""
	Debug function: Simulate many rolls to verify probability distribution
	Returns percentage breakdown of actual results
	"""
	var results = {
		"common": 0,
		"uncommon": 0, 
		"rare": 0,
		"epic": 0,
		"legendary": 0
	}
	
	for i in iterations:
		var item = get_luck_based_item(available_items, luck)
		if item:
			results[item.rarity] += 1
	
	# Convert to percentages
	for rarity in results:
		results[rarity] = (results[rarity] / float(iterations)) * 100.0
	
	return results
