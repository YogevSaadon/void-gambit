# scripts/actors/enemys/movment/ChaseMovement.gd
extends Node2D
class_name ChaseMovement

@export var speed_scale: float = 1.0

var enemy: BaseEnemy

func _enter_tree() -> void:
	enemy = get_parent() as BaseEnemy
	assert(enemy != null, "ChaseMovement expects a BaseEnemy parent")

func tick_movement(_delta: float) -> void:
	var player: Node2D = EnemyUtils.get_player() as Node2D
	if player == null:
		enemy.velocity = Vector2.ZERO
		return

	# Simple direction to player
	var dir: Vector2 = (player.global_position - enemy.global_position).normalized()
	enemy.velocity = dir * enemy.speed * speed_scale
	# Spacing is handled in BaseEnemy._apply_spacing()
