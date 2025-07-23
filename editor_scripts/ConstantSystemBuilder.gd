# scripts/tools/ConstantSystemBuilder.gd
@tool
extends EditorScript

func _run() -> void:
	print("=== Building Constants System ===")
	
	# Create directory structure
	_create_directories()
	
	# Create constant files with documentation
	_create_collision_layers()
	_create_combat_constants()
	_create_movement_constants()
	_create_enemy_constants()
	_create_weapon_constants()
	_create_ui_constants()
	_create_spawning_constants()
	_create_drop_constants()
	_create_status_constants()
	_create_performance_constants()
	
	# Create JSON data files
	_create_balance_config()
	_create_enemy_stats()
	_create_weapon_stats()
	_create_rarity_tables()
	_create_wave_progression()
	
	print("=== Constants System Built Successfully! ===")
	print("Check scripts/constants/ folder")

func _create_directories() -> void:
	var dir = DirAccess.open("res://")
	dir.make_dir_recursive("scripts/constants")
	dir.make_dir_recursive("scripts/constants/data")
	print("✓ Created directory structure")

func _create_collision_layers() -> void:
	var content = """# scripts/constants/CollisionLayers.gd
class_name CollisionLayers
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Player.gd (collision setup)
# - BaseEnemy.gd (collision setup)
# - All projectile scripts (bullets, explosions, missiles)
# - Contact damage systems
# - Weapon targeting systems

# ===== IMPLEMENTATION STEPS =====
# 1. Search for: collision_layer = 1 << [number]
# 2. Search for: collision_mask = 1 << [number]
# 3. Search for: collision_mask = [number]
# 4. Replace magic numbers with these constants

# ===== CONSTANTS TO DEFINE =====
# TODO: Define layer numbers (currently using magic numbers 1,2,4,5)
# const LAYER_PLAYER = ?
# const LAYER_ENEMIES = ?
# const LAYER_PLAYER_PROJECTILES = ?
# const LAYER_ENEMY_PROJECTILES = ?

# ===== TESTING CHECKLIST =====
# [ ] Player takes damage from enemies
# [ ] Enemies take damage from player
# [ ] Projectiles hit correct targets
# [ ] No friendly fire
# [ ] Contact damage works
# [ ] Explosions affect correct targets
"""
	_save_file("scripts/constants/CollisionLayers.gd", content)

func _create_combat_constants() -> void:
	var content = """# scripts/constants/CombatConstants.gd
class_name CombatConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - All damage calculations
# - Critical hit system
# - Armor damage reduction
# - Status effect damage (infection, burn)
# - Damage number display
# - Player invulnerability frames

# ===== IMPLEMENTATION STEPS =====
# 1. Search for damage multipliers (0.33, 1.5, 0.05)
# 2. Search for crit-related values
# 3. Search for armor formula (100.0)
# 4. Search for status tick rates

# ===== CONSTANTS TO DEFINE =====
# TODO: Extract from weapon scripts (0.33 for ships, 1.5 for explosions)
# TODO: Extract from DamageNumber.gd (hold/fade times)
# TODO: Extract from Player.gd (invuln time)
# TODO: Extract from StatusComponent.gd (tick intervals)

# ===== TESTING CHECKLIST =====
# [ ] Damage values match original
# [ ] Crits work correctly
# [ ] Armor reduces damage properly
# [ ] Status effects tick at right rate
# [ ] Damage numbers display correctly
"""
	_save_file("scripts/constants/CombatConstants.gd", content)

func _create_movement_constants() -> void:
	var content = """# scripts/constants/MovementConstants.gd
class_name MovementConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Player movement (acceleration, rotation)
# - Enemy movement patterns (chase, strafe, orbit)
# - Ship movement behaviors
# - Projectile speeds and lifetimes
# - Blink system
# - Drop pickup magnetism

# ===== IMPLEMENTATION STEPS =====
# 1. Search in PlayerMovement.gd for timing values
# 2. Search in enemy movement scripts for ranges/speeds
# 3. Search for rotation speeds
# 4. Search for distance thresholds

# ===== CONSTANTS TO DEFINE =====
# TODO: Player movement (0.25, 0.30, 8.0, 12.0)
# TODO: Enemy ranges (250.0, 300.0, 600.0)
# TODO: Sawblade patterns (15.0, 3.0)
# TODO: Charge behaviors (800.0, 400.0)

# ===== TESTING CHECKLIST =====
# [ ] Player movement feels the same
# [ ] Enemy patterns unchanged
# [ ] Ships orbit correctly
# [ ] Charge attacks work
# [ ] Sawblades spin properly
"""
	_save_file("scripts/constants/MovementConstants.gd", content)

func _create_enemy_constants() -> void:
	var content = """# scripts/constants/EnemyConstants.gd
class_name EnemyConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - All enemy base stats (health, speed, damage)
# - Enemy-specific behaviors
# - Contact damage values
# - Power level scaling
# - Enemy spawn requirements

# ===== IMPLEMENTATION STEPS =====
# 1. Extract base stats from each enemy script
# 2. Create methods to get stats by enemy type
# 3. Link to enemy_stats.json for designer tweaking

# ===== CONSTANTS TO DEFINE =====
# TODO: Move all base stats from enemy scripts
# TODO: Define which stats should be in JSON vs code
# TODO: Create stat getter methods

# ===== DATA FILE =====
# See: scripts/constants/data/enemy_stats.json

# ===== TESTING CHECKLIST =====
# [ ] Each enemy has correct health
# [ ] Movement speeds match original
# [ ] Contact damage works
# [ ] Power scaling applies correctly
"""
	_save_file("scripts/constants/EnemyConstants.gd", content)

func _create_weapon_constants() -> void:
	var content = """# scripts/constants/WeaponConstants.gd
class_name WeaponConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - All weapon damage values
# - Fire rates and cooldowns
# - Projectile speeds and lifetimes
# - Special weapon properties (laser reflects, explosion radius)
# - Weapon-specific multipliers

# ===== IMPLEMENTATION STEPS =====
# 1. Extract base damage/fire rate from weapon scripts
# 2. Find all projectile speeds (1800, 400, 450)
# 3. Extract special multipliers (0.05 for laser, 1.5 for explosion)
# 4. Link to weapon_stats.json

# ===== CONSTANTS TO DEFINE =====
# TODO: Base weapon stats
# TODO: Projectile properties
# TODO: Special ability values
# TODO: Ship weapon reductions (0.33)

# ===== DATA FILE =====
# See: scripts/constants/data/weapon_stats.json

# ===== TESTING CHECKLIST =====
# [ ] Bullet damage correct
# [ ] Laser tick damage correct
# [ ] Explosion radius correct
# [ ] Fire rates unchanged
# [ ] Ship weapons do 33% damage
"""
	_save_file("scripts/constants/WeaponConstants.gd", content)

func _create_ui_constants() -> void:
	var content = """# scripts/constants/UIConstants.gd
class_name UIConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Damage number display
# - Health/shield bar sizing
# - UI animations and transitions
# - Color schemes for rarities
# - Text formatting

# ===== IMPLEMENTATION STEPS =====
# 1. Extract from DamageNumber.gd (timing, speed)
# 2. Find rarity colors in PassiveItem.gd
# 3. Extract UI animation durations
# 4. Find text size constants

# ===== CONSTANTS TO DEFINE =====
# TODO: Damage number behavior (0.08, 0.40, 30.0)
# TODO: Rarity colors
# TODO: UI transition times
# TODO: Bar sizes and offsets

# ===== TESTING CHECKLIST =====
# [ ] Damage numbers float correctly
# [ ] Rarity colors match
# [ ] UI animations smooth
# [ ] Text readable
"""
	_save_file("scripts/constants/UIConstants.gd", content)

func _create_spawning_constants() -> void:
	var content = """# scripts/constants/SpawningConstants.gd
class_name SpawningConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Power budget calculations
# - Spawn intervals and batch sizes
# - Wave duration and progression
# - Enemy tier multipliers
# - Golden ship spawning

# ===== IMPLEMENTATION STEPS =====
# 1. Extract from PowerBudgetCalculator.gd
# 2. Find spawn timing in WaveManager.gd
# 3. Extract tier breakpoints and multipliers
# 4. Link to wave_progression.json

# ===== CONSTANTS TO DEFINE =====
# TODO: Power budget formula values
# TODO: Spawn intervals (10.0, 0.3)
# TODO: Tier breakpoints (6, 12, 18, 24)
# TODO: Duration scaling (30.0 to 60.0)

# ===== DATA FILE =====
# See: scripts/constants/data/wave_progression.json

# ===== TESTING CHECKLIST =====
# [ ] Wave difficulty scales correctly
# [ ] Spawn timing feels right
# [ ] Golden ships appear on schedule
# [ ] Power budgets balanced
"""
	_save_file("scripts/constants/SpawningConstants.gd", content)

func _create_drop_constants() -> void:
	var content = """# scripts/constants/DropConstants.gd
class_name DropConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Credit/coin drop values
# - Pickup magnetism behavior
# - Drop movement physics
# - Collection thresholds

# ===== IMPLEMENTATION STEPS =====
# 1. Extract from DropPickup.gd
# 2. Find drop value multipliers
# 3. Extract movement parameters

# ===== CONSTANTS TO DEFINE =====
# TODO: Pickup ranges (120.0, 15.0)
# TODO: Movement speeds (200.0, 2000.0)
# TODO: Acceleration curves (3.0, 2.5)
# TODO: Drop value multipliers

# ===== TESTING CHECKLIST =====
# [ ] Drops magnetize at right distance
# [ ] Collection feels smooth
# [ ] Values match original
"""
	_save_file("scripts/constants/DropConstants.gd", content)

func _create_status_constants() -> void:
	var content = """# scripts/constants/StatusConstants.gd
class_name StatusConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Infection/bio damage behavior
# - Status effect durations
# - Tick intervals and damage
# - Spread mechanics
# - Stack limits

# ===== IMPLEMENTATION STEPS =====
# 1. Extract from StatusComponent.gd
# 2. Find bio weapon values
# 3. Extract spread chances

# ===== CONSTANTS TO DEFINE =====
# TODO: Tick intervals (0.5)
# TODO: Max stacks (3)
# TODO: Damage multipliers per stack (0.33)
# TODO: Spread radius and chance

# ===== TESTING CHECKLIST =====
# [ ] Infection damage correct
# [ ] Spreading works
# [ ] Stacking applies properly
# [ ] Duration correct
"""
	_save_file("scripts/constants/StatusConstants.gd", content)

func _create_performance_constants() -> void:
	var content = """# scripts/constants/PerformanceConstants.gd
class_name PerformanceConstants
extends RefCounted

# ===== WHAT THIS AFFECTS =====
# - Update intervals for expensive operations
# - Spatial query limits
# - Cache durations
# - Maximum entity counts

# ===== IMPLEMENTATION STEPS =====
# 1. Find all timer intervals (0.1, 0.2)
# 2. Find spatial query limits (32)
# 3. Extract cache timings

# ===== CONSTANTS TO DEFINE =====
# TODO: Distance check intervals
# TODO: Target update frequencies
# TODO: Maximum query results
# TODO: Validation timings

# ===== TESTING CHECKLIST =====
# [ ] No performance regression
# [ ] Queries return enough results
# [ ] Updates frequent enough
"""
	_save_file("scripts/constants/PerformanceConstants.gd", content)

# JSON Data Files

func _create_balance_config() -> void:
	var content = """{
  "combat": {
	"damage_numbers": {
	  "hold_time": 0.08,
	  "fade_time": 0.40,
	  "float_speed": 30.0,
	  "count_speed": 60.0
	},
	"player": {
	  "invuln_time": 0.3,
	  "death_delay": 0.2
	}
  },
  "economy": {
	"credit_drop_multiplier": 4.0,
	"golden_coin_value": 1.0
  }
}"""
	_save_file("scripts/constants/data/balance_config.json", content)

func _create_enemy_stats() -> void:
	var content = """{
  "_instructions": "Extract all base enemy stats here for easy balancing",
  "biter": {
	"base_health": 20,
	"base_speed": 120,
	"contact_damage": 12
  }
}"""
	_save_file("scripts/constants/data/enemy_stats.json", content)

func _create_weapon_stats() -> void:
	var content = """{
  "_instructions": "Base weapon stats for balancing",
  "bullet": {
	"base_damage": 20,
	"fire_rate": 1.0,
	"projectile_speed": 1800
  }
}"""
	_save_file("scripts/constants/data/weapon_stats.json", content)

func _create_rarity_tables() -> void:
	var content = """{
  "_instructions": "Store and slot machine rarity tables",
  "level_rarity_table": {},
  "luck_scaling": {}
}"""
	_save_file("scripts/constants/data/rarity_tables.json", content)

func _create_wave_progression() -> void:
	var content = """{
  "_instructions": "Wave timing and power progression",
  "power_budget_scaling": {},
  "tier_breakpoints": {}
}"""
	_save_file("scripts/constants/data/wave_progression.json", content)

func _save_file(path: String, content: String) -> void:
	var file = FileAccess.open("res://" + path, FileAccess.WRITE)
	file.store_string(content)
	file.close()
	print("✓ Created: " + path)
