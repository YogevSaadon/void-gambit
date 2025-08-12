@tool
# scripts/tools/SmartCollisionMigration.gd
extends EditorScript

var total_replacements: int = 0
var files_checked: int = 0

func _run() -> void:
	print("\n=== SMART COLLISION LAYER MIGRATION ===")
	print("This will find and replace collision layer magic numbers\n")
	
	# Step 1: Create CollisionLayers.gd
	_create_collision_layers_script()
	
	# Step 2: Find and replace in all relevant files
	_find_and_replace_collision_layers()
	
	# Step 3: Summary
	print("\n=== MIGRATION COMPLETE ===")
	print("Files checked: %d" % files_checked)
	print("Total replacements: %d" % total_replacements)
	
	if total_replacements == 0:
		print("\n⚠️ NO CHANGES MADE - Possible reasons:")
		print("- Files already migrated")
		print("- Line patterns don't match exactly")
		print("- Files not found at expected paths")

func _create_collision_layers_script() -> void:
	var content = """class_name CollisionLayers
extends RefCounted

# ===== COLLISION LAYERS =====
# Layer numbers as they appear in code (bit positions)
const LAYER_PLAYER = 1              # Bit 1 = Layer 2 in inspector
const LAYER_ENEMIES = 2             # Bit 2 = Layer 3 in inspector
const LAYER_PLAYER_PROJECTILES = 4  # Bit 4 = Layer 5 in inspector
const LAYER_ENEMY_PROJECTILES = 5   # Bit 5 = Layer 6 in inspector

# ===== COLLISION MASKS =====
const MASK_PLAYER = 0                      # Player detects nothing
const MASK_ENEMIES = 0                     # Enemies detect nothing
const MASK_PLAYER_PROJECTILES = 1 << 2     # Detect enemies (bit 2)
const MASK_ENEMY_PROJECTILES = 1 << 1      # Detect player (bit 1)
"""
	
	# Ensure directory exists
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("scripts/constants"):
		dir.make_dir_recursive("scripts/constants")
	
	# Write file
	var file = FileAccess.open("res://scripts/constants/CollisionLayers.gd", FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.flush()
		file = null  # This closes the file in Godot 4
		print("Created CollisionLayers.gd")
	else:
		print("Failed to create CollisionLayers.gd")

func _find_and_replace_collision_layers() -> void:
	# Define search and replace patterns
	var replacements = [
		# Player collision
		{
			"files": ["scripts/actors/player/Player.gd"],
			"patterns": [
				{"find": "collision_layer = 1 << 1", "replace": "collision_layer = 1 << CollisionLayers.LAYER_PLAYER"},
				{"find": "collision_mask = 0", "replace": "collision_mask = CollisionLayers.MASK_PLAYER"}
			]
		},
		
		# BaseEnemy collision
		{
			"files": ["scripts/actors/enemys/base-enemy/BaseEnemy.gd"],
			"patterns": [
				{"find": "collision_layer = 1 << 2", "replace": "collision_layer = 1 << CollisionLayers.LAYER_ENEMIES"},
				{"find": "collision_mask = 0", "replace": "collision_mask = CollisionLayers.MASK_ENEMIES"}
			]
		},
		
		# Player bullets
		{
			"files": ["scripts/projectiles/player_projectiles/PlayerBullet.gd"],
			"patterns": [
				{"find": "bullet_collision_layer = 4", "replace": "bullet_collision_layer = CollisionLayers.LAYER_PLAYER_PROJECTILES"},
				{"find": "bullet_collision_mask = 2", "replace": "bullet_collision_mask = CollisionLayers.MASK_PLAYER_PROJECTILES"}
			]
		},
		
		# Enemy bullets
		{
			"files": ["scripts/projectiles/enemy_projectiles/EnemyBullet.gd"],
			"patterns": [
				{"find": "bullet_collision_layer = 5", "replace": "bullet_collision_layer = CollisionLayers.LAYER_ENEMY_PROJECTILES"},
				{"find": "bullet_collision_mask = 1", "replace": "bullet_collision_mask = CollisionLayers.MASK_ENEMY_PROJECTILES"}
			]
		},
		
		# Explosions
		{
			"files": ["scripts/projectiles/player_projectiles/PlayerExplosion.gd"],
			"patterns": [
				{"find": "explosion_collision_layer = 4", "replace": "explosion_collision_layer = CollisionLayers.LAYER_PLAYER_PROJECTILES"},
				{"find": "explosion_collision_mask = 2", "replace": "explosion_collision_mask = CollisionLayers.MASK_PLAYER_PROJECTILES"}
			]
		},
		
		{
			"files": ["scripts/projectiles/enemy_projectiles/EnemyExplosion.gd"],
			"patterns": [
				{"find": "explosion_collision_layer = 5", "replace": "explosion_collision_layer = CollisionLayers.LAYER_ENEMY_PROJECTILES"},
				{"find": "explosion_collision_mask = 1", "replace": "explosion_collision_mask = CollisionLayers.MASK_ENEMY_PROJECTILES"}
			]
		},
		
		# Contact damage
		{
			"files": ["scripts/actors/enemys/base-enemy/ContactDamage.gd"],
			"patterns": [
				{"find": "zone.collision_mask = 1 << 1", "replace": "zone.collision_mask = 1 << CollisionLayers.LAYER_PLAYER"}
			]
		},
		
		# Missile
		{
			"files": ["scripts/projectiles/player_projectiles/PlayerMissile.gd"],
			"patterns": [
				{"find": "collision_layer = 1 << 4", "replace": "collision_layer = 1 << CollisionLayers.LAYER_PLAYER_PROJECTILES"},
				{"find": "collision_mask  = 1 << 2", "replace": "collision_mask = 1 << CollisionLayers.LAYER_ENEMIES"}
			]
		},
		
		# Spatial queries in various files
		{
			"files": [
				"scripts/weapons/ShooterWeapon.gd",
				"scripts/weapons/laser/ChainLaserBeamController.gd",
				"scripts/weapons/spawners/TargetSelector.gd",
				"scripts/weapons/spawners/UniversalShipWeapon.gd",
				"scripts/actors/enemys/movment/BaseRangeKeepingMovement.gd"
			],
			"patterns": [
				{"find": "params.collision_mask = 1 << 2", "replace": "params.collision_mask = 1 << CollisionLayers.LAYER_ENEMIES"}
			]
		}
	]
	
	# Process each file group
	for group in replacements:
		for file_path in group.files:
			_process_file(file_path, group.patterns)

func _process_file(file_path: String, patterns: Array) -> void:
	var full_path = "res://" + file_path
	files_checked += 1
	
	# Check if file exists
	if not FileAccess.file_exists(full_path):
		print("⚠️ File not found: %s" % file_path)
		return
	
	# Read file content
	var file = FileAccess.open(full_path, FileAccess.READ)
	if not file:
		print("❌ Cannot read: %s" % file_path)
		return
	
	var content = file.get_as_text()
	file = null  # Close file
	
	# Track changes
	var original_content = content
	var changes_made = 0
	
	# Apply each pattern
	for pattern in patterns:
		var find_text = pattern.find
		var replace_text = pattern.replace
		
		# Count occurrences
		var occurrences = content.count(find_text)
		if occurrences > 0:
			content = content.replace(find_text, replace_text)
			changes_made += occurrences
			total_replacements += occurrences
			print("  ✓ Replaced '%s' → '%s' (%d times)" % [find_text, replace_text, occurrences])
	
	# Write back if changes were made
	if changes_made > 0:
		file = FileAccess.open(full_path, FileAccess.WRITE)
		if file:
			file.store_string(content)
			file.flush()
			file = null  # Close file
			print("✓ Updated %s (%d replacements)" % [file_path.get_file(), changes_made])
		else:
			print("❌ Cannot write to: %s" % file_path)
	else:
		print("  No changes needed in: %s" % file_path.get_file())

# Helper function to check what's actually in a file
func debug_file_content(file_path: String, search_term: String) -> void:
	var full_path = "res://" + file_path
	if FileAccess.file_exists(full_path):
		var file = FileAccess.open(full_path, FileAccess.READ)
		if file:
			var line_num = 1
			while not file.eof_reached():
				var line = file.get_line()
				if search_term in line:
					print("Line %d: %s" % [line_num, line.strip_edges()])
				line_num += 1
			file = null
