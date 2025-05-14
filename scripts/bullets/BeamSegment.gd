extends Node2D
class_name BeamSegment

@onready var line : Line2D    = $Line2D
@onready var ray  : RayCast2D = $RayCast2D

func update_segment(start: Vector2, end: Vector2) -> void:
	global_position = start
	var local_end   = end - start
	line.points     = [Vector2.ZERO, local_end]
	ray.target_position = local_end
	ray.force_raycast_update()
