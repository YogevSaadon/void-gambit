# /scripts/actors/enemys/base-enemy/ChaseMovement.gd
extends Node2D
class_name ChaseMovement
var enemy: BaseEnemy
@export var speed_scale: float = 1.0

func tick_movement(_delta:float)->void:
	var p = EnemyUtils.get_player()
	if not p: return
	var dir = (p.global_position - enemy.global_position).normalized()
	enemy.velocity = dir * enemy.speed * speed_scale
	enemy.move_and_slide()
