# DEBUG CLEANUP SCRIPT
# Save this as "cleanup_debug.gd" and run it via Tools → Execute Script
# This script will remove debug print statements from your project

@tool
extends EditorScript

func _run():
	print("=== STARTING DEBUG CLEANUP ===")
	
	var files_to_clean = [
		# Store/Hangar debug files
		"res://scripts/game/hangar/StoreLevelRarityLogic.gd",
		"res://scripts/game/hangar/StorePanel.gd", 
		"res://scripts/game/hangar/SlotMachinePanel.gd",
		"res://scripts/game/hangar/SlotMachineLogic.gd",
		
		# Wave/Spawning debug files
		"res://scripts/game/managers/WaveManager.gd",
		"res://scripts/game/spawning/PowerBudgetSpawner.gd",
		"res://scripts/game/spawning/EnemyPool.gd",
		"res://scripts/game/spawning/PowerBudgetCalculator.gd",
		"res://scripts/game/spawning/GoldenShipSpawner.gd",
		
		# Weapon/Ship debug files
		"res://scripts/weapons/spawners/UniversalShipSpawner.gd",
		"res://scripts/weapons/spawners/UniversalShipWeapon.gd",
		"res://scripts/weapons/spawners/MiniShipMovement.gd",
		"res://scripts/weapons/spawners/TargetSelector.gd",
		"res://scripts/weapons/spawners/MiniShip.gd",
		
		# Player/Game debug files
		"res://scripts/actors/player/Player.gd",
		"res://scripts/game/Level.gd",
		"res://scripts/game/ItemDatabase.gd",
		"res://scripts/actors/enemys/enemy-scripts/GoldShip.gd",
		"res://scripts/actors/enemys/enemy-scripts/Swarm.gd",
		"res://scripts/game/hangar/Hangar.gd"
	]
	
	var total_cleaned = 0
	var total_lines_removed = 0
	
	for file_path in files_to_clean:
		var result = clean_file(file_path)
		if result.success:
			total_cleaned += 1
			total_lines_removed += result.lines_removed
			print("✅ Cleaned %s (%d debug lines removed)" % [file_path.get_file(), result.lines_removed])
		else:
			print("❌ Failed to clean %s: %s" % [file_path.get_file(), result.error])
	
	print("\n=== CLEANUP COMPLETE ===")
	print("Files cleaned: %d/%d" % [total_cleaned, files_to_clean.size()])
	print("Total debug lines removed: %d" % total_lines_removed)
	print("\n🎯 YOUR CONSOLE SHOULD NOW BE MUCH CLEANER!")

func clean_file(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		return {"success": false, "error": "File not found", "lines_removed": 0}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {"success": false, "error": "Could not open file", "lines_removed": 0}
	
	var original_content = file.get_as_text()
	file.close()
	
	var lines = original_content.split("\n")
	var cleaned_lines = []
	var lines_removed = 0
	
	for line in lines:
		var trimmed = line.strip_edges()
		
		# Skip debug print statements
		if should_remove_line(trimmed):
			lines_removed += 1
			continue
		
		cleaned_lines.append(line)
	
	# Only write if we actually removed something
	if lines_removed > 0:
		var cleaned_content = "\n".join(cleaned_lines)
		
		var write_file = FileAccess.open(file_path, FileAccess.WRITE)
		if not write_file:
			return {"success": false, "error": "Could not write file", "lines_removed": 0}
		
		write_file.store_string(cleaned_content)
		write_file.close()
	
	return {"success": true, "error": "", "lines_removed": lines_removed}

func should_remove_line(line: String) -> bool:
	# Remove lines that start with print statements
	if line.begins_with("print("):
		return true
	
	# Remove lines that are only print statements (with tabs/spaces)
	if line.strip_edges().begins_with("print("):
		return true
	
	# Remove specific debug patterns
	var debug_patterns = [
		"print(\"=== ",
		"print(\"Store Level",
		"print(\"STORE Level", 
		"print(\"Store Milestone",
		"print(\"STORE MILESTONE",
		"print(\"Pity Status",
		"print(\"PITY TRIGGERED",
		"print(\"Store (",
		"print(\"Wave Manager",
		"print(\"WaveManager:",
		"print(\"=== SPAWNING",
		"print(\"=== STARTING LEVEL",
		"print(\"=== LEVEL %d COMPLETED",
		"print(\"Batch %d:",
		"print(\"Spawned Golden Ship",
		"print(\"PowerBudget Level",
		"print(\"EnemyPool:",
		"print(\"Applied %dx tier scaling",
		"print(\"=== SPAWN SUMMARY",
		"print(\"=== DETAILED SPAWN LIST",
		"print(\"Budget:",
		"print(\"Spawned:",
		"print(\"Efficiency:",
		"print(\"Enemy variety:",
		"print(\"Equipped %s in slot",
		"print(\"All weapon slots full",
		"print(\"Purchased passive item:",
		"print(\"Purchased weapon:",
		"print(\"ItemDatabase: Loaded",
		"print(\"SlotMachine:",
		"print(\"Slot machine gave",
		"print(\"Gold Ship dropped",
		"print(\"Swarm (power",
		"print(\"Swarm: Spawning",
		"print(\"Swarm: Successfully spawned",
		"print(\"Spawned %s ship",
		"print(\"Ship Bullet Weapon:",
		"print(\"EnhancedShipMovement: Initialized",
		"print(\"TargetSelector: Switched to new target",
		"print(\"MiniShip: Weapon attached",
		"print(\"Armor:",
		"print(\"Tank charging!",
		"print(\"Tank charge complete"
	]
	
	for pattern in debug_patterns:
		if line.contains(pattern):
			return true
	
	return false
