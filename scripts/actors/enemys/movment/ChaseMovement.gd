# /scripts/enemies/movements/ChaseMovement.gd
extends Node2D
class_name ChaseMovement

@export var speed_scale : float = 1.0

var enemy : BaseEnemy            # filled in _enter_tree()

func _enter_tree() -> void:
	enemy = get_parent() as BaseEnemy
	assert(enemy != null, "ChaseMovement expects a BaseEnemy parent")

func tick_movement(_delta: float) -> void:
	# Get the player as a typed Node2D so the inspector can see global_position
	var player : Node2D = EnemyUtils.get_player() as Node2D
	if player == null:
		return

	# Vector2 is now fully typed – no inference complaint
	var dir : Vector2 = (player.global_position - enemy.global_position).normalized()
	enemy.velocity = dir * enemy.speed * speed_scale
	enemy.move_and_slide()
