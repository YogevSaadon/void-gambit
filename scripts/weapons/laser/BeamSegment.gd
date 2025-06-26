extends Node2D
class_name BeamSegment

@onready var line : Line2D    = $Line2D
@onready var ray  : RayCast2D = $RayCast2D

## Update this segment to connect start → end
func update_segment(start: Vector2, end: Vector2) -> void:
	# Move the segment’s origin to the start point
	global_position = start

	# Work in local space for Line2D / RayCast2D
	var local_end: Vector2 = end - start

	# Draw line
	line.points = [Vector2.ZERO, local_end]

	# Stretch RayCast to same length
	ray.target_position = local_end
	ray.force_raycast_update()
