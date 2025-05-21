extends Area2D
class_name EnemyCollisionNode

@export var repulsion_force: float = 50.0  # Adjust as needed

var enemy: Node2D  # Reference to the enemy this node is attached to

func _enter_tree():
	# Set collision layer to 4 and mask to detect only layer 4
	collision_layer = 1 << 3  # layer 4 (bit index 3)
	collision_mask = 1 << 3   # detect only layer 4

func _ready():
	enemy = get_parent() as Node2D  # Assume this node is a child of the enemy node
	connect("area_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body is EnemyCollisionNode:
		var other_enemy = body.get_parent() as Node2D
		if other_enemy and other_enemy != enemy:
			# Calculate vector from the other enemy to this enemy
			var diff = enemy.global_position - other_enemy.global_position
			if diff.length() == 0:
				diff = Vector2(1, 0)  # Prevent division by zero
			diff = diff.normalized()
			# Apply repulsion force scaled by delta time for smooth movement
			enemy.global_position += diff * repulsion_force * get_physics_process_delta_time()
