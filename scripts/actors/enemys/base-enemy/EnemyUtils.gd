# scripts/actors/enemys/base-enemy/EnemyUtils.gd
extends Node
class_name EnemyUtils

# ─── Returns the first Player node in the "Player" group, or null if none ─────
static func get_player() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	var players := tree.get_nodes_in_group("Player")
	return players[0] if players.size() > 0 else null

# ─── Calculates a normalized direction vector from `from_node` to the player ──
static func direction_to_player(from_node: Node2D) -> Vector2:
	var player = get_player()
	if player:
		return (player.global_position - from_node.global_position).normalized()
	return Vector2.ZERO

# ─── Returns true if the player is within `radius` of `from_node` ────────────
static func is_player_within_radius(from_node: Node2D, radius: float) -> bool:
	var player = get_player()
	if player:
		return from_node.global_position.distance_to(player.global_position) <= radius
	return false
