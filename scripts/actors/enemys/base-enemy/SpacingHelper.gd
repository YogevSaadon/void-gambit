# scripts/actors/enemys/base-enemy/SpacingHelper.gd
extends Node
class_name SpacingHelper

@export var spacing_radius: float = 25.0
@export var spacing_force: float = 80.0
@export var enabled: bool = true
@export var debug: bool = false  # Enable debug prints

var enemy: BaseEnemy

func _ready() -> void:
	enemy = get_parent() as BaseEnemy
	if debug and enemy:
		print("SpacingHelper ready for enemy type: ", enemy.enemy_type)

func calculate_spacing_force() -> Vector2:
	if not enabled or not enemy:
		return Vector2.ZERO
	
	var separation = Vector2.ZERO
	var neighbor_count = 0
	
	# Get all enemies of the same type using groups
	var group_name = "Enemy_" + enemy.enemy_type
	var same_type_enemies = enemy.get_tree().get_nodes_in_group(group_name)
	
	if debug and same_type_enemies.size() > 1:
		print("Found %d enemies in group %s" % [same_type_enemies.size(), group_name])
	
	for other in same_type_enemies:
		if other == enemy:
			continue
		
		# Pure distance calculation - no physics!
		var distance = enemy.global_position.distance_to(other.global_position)
		
		if distance > 0 and distance < spacing_radius:
			# Calculate push direction
			var diff = enemy.global_position - other.global_position
			# Stronger push when closer
			var push_strength = 1.0 - (distance / spacing_radius)
			separation += diff.normalized() * push_strength
			neighbor_count += 1
	
	if neighbor_count > 0:
		if debug:
			print("Spacing: %d neighbors, force: %v" % [neighbor_count, separation.normalized() * spacing_force])
		return separation.normalized() * spacing_force
	
	return Vector2.ZERO
