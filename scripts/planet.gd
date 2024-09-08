@tool
class_name Planet
extends Node3D

@export
var y_rotation_speed: float = 0.02;

func _process(delta: float) -> void:
	rotate_y(y_rotation_speed * delta)
