extends "res://scripts/actors/Actor.gd"
class_name Enemy

@export var damage: int = 10

func _ready():
	add_to_group("Enemies")
	# Basic stats for a small enemy
	max_health = 20
	health = 20
	speed = 50  # Use the exported move_speed for movement

func _physics_process(delta):
	# Recharge shield (if any)
	recharge_shield(delta)
	
	# Get the target player from the "Player" group
	var player = get_target_player()
	if player:
		# Calculate normalized direction toward the player's global position
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

# Helper function to get the first player in the "Player" group.
func get_target_player() -> Node:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		return players[0]
	return null
