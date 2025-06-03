# /scripts/actors/enemys/base-enemy/PowerIndicator.gd
extends Node2D
class_name PowerIndicator

@onready var rect := $ColorRect

func apply_power_level(level:int) -> void:
	var c : Color = Color.WHITE
	match level:
		1:  c = Color(1,1,1)       # white
		2:  c = Color(0,1,0)       # green
		4:  c = Color(0.2,0.6,1)   # blue
		_:  c = Color(0.6,0,1)     # purple / anything 8+
	rect.color = c
