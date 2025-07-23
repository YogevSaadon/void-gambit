@tool
# scripts/tools/AutoMigrateCollisionLayers.gd
extends EditorScript

var files_modified: int = 0
var changes_made: Array = []

func _run() -> void:
	print("\n=== COLLISION LAYER AUTOMATIC MIGRATION ===")
	
	# Step 1: Create the complete CollisionLayers.gd file
	_create_collision_layers_script()
	
	# Step 2: Migrate all files automatically
	_migrate_all_files()
	
	# Step 3: Print summary
	_print_summary()

func _create_collision_layers_script() -> void:
	var content = """# scripts/constants/CollisionLayers.gd
class_name CollisionLayers
extends RefCounted

# ===== COLLISION LAYERS =====
# Bit positions for collision layers (0-31)
const LAYER_PLAYER = 1                # Player character
const LAYER_ENEMIES = 2               # All enemy entities  
const LAYER_PLAYER_PROJECTILES = 4    # Bullets, lasers, missiles from player
const LAYER_ENEMY_PROJECTILES = 5     # Bullets, explosions from enemies

# ===== COLLISION MASKS =====
# What each layer can detect (0 means no collision detection)
const MASK_PLAYER = 0                                      # Player detects nothing
const MASK_ENEMIES = 0                                     # Enemies detect nothing
const MASK_PLAYER_PROJECTILES = 1 << LAYER_ENEMIES        # Player projectiles detect enemies
const MASK_ENEMY_PROJECTILES = 1 << LAYER_PLAYER          # Enemy projectiles detect player

# ===== HELPER FUNCTIONS =====
static func get_layer_bit(layer: int) -> int:
	return 1 << layer

static func get_layer_name(layer: int) -> String:
	match layer:
		LAYER_PLAYER: return "Player"
		LAYER_ENEMIES: return "Enemies"
		LAYER_PLAYER_PROJECTILES: return "Player Projectiles"
		LAYER_ENEMY_PROJECTILES: return "Enemy Projectiles"
		_: return "Unknown Layer %d" % layer
"""
	
	# Create directory if needed
	var dir = DirAccess.open("res://")
	dir.make_dir_recursive("scripts/constants")
	
	# Save the file
	var file = FileAccess.open("res://scripts/constants/CollisionLayers.gd", FileAccess.WRITE)
	file.store_string(content)
	file.close()
	print("✓ Created CollisionLayers.gd")

func _migrate_all_files() -> void:
	# Player.gd
	_migrate_file(
		"scripts/actors/player/Player.gd",
		[
			{"old": "collision_layer = 1 << 1", "new": "collision_layer = 1 << CollisionLayers.LAYER_PLAYER"},
			{"old": "collision_mask = 0", "new": "collision_mask = CollisionLayers.MASK_PLAYER"}
		]
	)
	
	# BaseEnemy.gd
	_migrate_file(
		"scripts/actors/enemys/base-enemy/BaseEnemy.gd",
		[
			{"old": "collision_layer = 1 << 2", "new": "collision_layer = 1 << CollisionLayers.LAYER_ENEMIES"},
			{"old": "collision_mask = 0", "new": "collision_mask = CollisionLayers.MASK_ENEMIES"}
		]
	)
	
	# PlayerBullet.gd
	_migrate_file(
		"scripts/projectiles/player_projectiles/PlayerBullet.gd",
		[
			{"old": "bullet_collision_layer = 4", "new": "bullet_collision_layer = CollisionLayers.LAYER_PLAYER_PROJECTILES"},
			{"old": "bullet_collision_mask = 2", "new": "bullet_collision_mask = CollisionLayers.MASK_PLAYER_PROJECTILES"}
		]
	)
	
	# EnemyBullet.gd
	_migrate_file(
		"scripts/projectiles/enemy_projectiles/EnemyBullet.gd",
		[
			{"old": "bullet_collision_layer = 5", "new": "bullet_collision_layer = CollisionLayers.LAYER_ENEMY_PROJECTILES"},
			{"old": "bullet_collision_mask = 1", "new": "bullet_collision_mask = CollisionLayers.MASK_ENEMY_PROJECTILES"}
		]
	)
	
	# PlayerExplosion.gd
	_migrate_file(
		"scripts/projectiles/player_projectiles/PlayerExplosion.gd",
		[
			{"old": "explosion_collision_layer = 4", "new": "explosion_collision_layer = CollisionLayers.LAYER_PLAYER_PROJECTILES"},
			{"old": "explosion_collision_mask = 2", "new": "explosion_collision_mask = CollisionLayers.MASK_PLAYER_PROJECTILES"}
		]
	)
	
	# EnemyExplosion.gd
	_migrate_file(
		"scripts/projectiles/enemy_projectiles/EnemyExplosion.gd",
		[
			{"old": "explosion_collision_layer = 5", "new": "explosion_collision_layer = CollisionLayers.LAYER_ENEMY_PROJECTILES"},
			{"old": "explosion_collision_mask = 1", "new": "explosion_collision_mask = CollisionLayers.MASK_ENEMY_PROJECTILES"}
		]
	)
	
	# ContactDamage.gd
	_migrate_file(
		"scripts/actors/enemys/base-enemy/ContactDamage.gd",
		[
			{"old": "zone.collision_mask = 1 << 1", "new": "zone.collision_mask = 1 << CollisionLayers.LAYER_PLAYER"}
		]
	)
	
	# Missile.gd
	_migrate_file(
		"scripts/projectiles/player_projectiles/PlayerMissile.gd",
		[
			{"old": "collision_layer = 1 << 4", "new": "collision_layer = 1 << CollisionLayers.LAYER_PLAYER_PROJECTILES"},
			{"old": "collision_mask  = 1 << 2", "new": "collision_mask = 1 << CollisionLayers.LAYER_ENEMIES"}
		]
	)
	
	# All weapon scripts that use collision masks for targeting
	var weapon_files = [
		"scripts/weapons/ShooterWeapon.gd",
		"scripts/weapons/laser/ChainLaserBeamController.gd",
		"scripts/actors/enemys/movment/TriangleMovement.gd",
		"scripts/actors/enemys/movment/BaseChaseMovement.gd",
		"scripts/weapons/spawners/TargetSelector.gd",
		"scripts/weapons/spawners/UniversalShipWeapon.gd"
	]
	
	for file_path in weapon_files:
		_migrate_file(
			file_path,
			[
				{"old": "params.collision_mask = 1 << 2", "new": "params.collision_mask = 1 << CollisionLayers.LAYER_ENEMIES"}
			]
		)
	
	# Fix BaseBullet.gd and BaseExplosion.gd to not double-shift
	_migrate_file(
		"scripts/projectiles/BaseBullet.gd",
		[
			{"old": "collision_mask  = 1 << bullet_collision_mask", "new": "collision_mask = bullet_collision_mask"}
		]
	)
	
	_migrate_file(
		"scripts/projectiles/BaseExplosion.gd",
		[
			{"old": "collision_mask = 1 << explosion_collision_mask", "new": "collision_mask = explosion_collision_mask"}
		]
	)

func _migrate_file(file_path: String, replacements: Array) -> void:
	var full_path = "res://" + file_path
	
	# Check if file exists
	if not FileAccess.file_exists(full_path):
		print("⚠ File not found: " + file_path)
		return
	
	# Read file content
	var file = FileAccess.open(full_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var original_content = content
	var changes_in_file = 0
	
	# Apply all replacements
	for replacement in replacements:
		var old_text = replacement.old
		var new_text = replacement.new
		
		if content.contains(old_text):
			content = content.replace(old_text, new_text)
			changes_in_file += 1
			changes_made.append({
				"file": file_path,
				"old": old_text,
				"new": new_text
			})
	
	# Write back if changes were made
	if changes_in_file > 0:
		file = FileAccess.open(full_path, FileAccess.WRITE)
		file.store_string(content)
		file.close()
		files_modified += 1
		print("✓ Modified %s (%d changes)" % [file_path, changes_in_file])
	else:
		print("  No changes needed in: " + file_path)

func _print_summary() -> void:
	print("\n=== MIGRATION COMPLETE ===")
	print("Files modified: %d" % files_modified)
	print("Total changes: %d" % changes_made.size())
	
	if changes_made.size() > 0:
		print("\nChanges made:")
		for change in changes_made:
			print("  %s:" % change.file)
			print("    OLD: %s" % change.old)
			print("    NEW: %s" % change.new)
	
	print("\n=== TESTING CHECKLIST ===")
	print("[ ] Run the game")
	print("[ ] Player bullets hit enemies")
	print("[ ] Enemy bullets hit player")
	print("[ ] Contact damage works")
	print("[ ] Explosions work correctly")
	print("[ ] Laser targeting works")
	print("[ ] No collision between same-team projectiles")
	print("\nIf any issues, you can revert with version control!")
