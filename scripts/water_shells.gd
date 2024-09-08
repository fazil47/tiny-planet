@tool
class_name WaterShells

extends MultiMeshInstance3D

@export_range(1, 128)
var num_shells: int = 32:
	set(new_shells):
		num_shells = new_shells
		setup_shells()

@export
var base_radius: float = 5:
	set(new_base_radius):
		base_radius = new_base_radius
		setup_shells()

@export_range(0.001, 10)
var gap: float = 0.01:
	set(new_gap):
		gap = new_gap
		setup_shells()

func _ready() -> void:
	setup_shells()

func setup_shells() -> void:
	var sphere_mesh: SphereMesh = multimesh.mesh
	sphere_mesh.radius = base_radius
	sphere_mesh.height = 2 * base_radius
	
	multimesh.instance_count = num_shells

	for i in range(num_shells):
		var height_normalized := float(i) / num_shells
		var radius := base_radius + (i * gap)
		var instance_scale := radius / base_radius
		var instance_transform = transform.scaled(Vector3(instance_scale, instance_scale, instance_scale))
		
		multimesh.set_instance_transform(i, instance_transform)
		multimesh.set_instance_custom_data(i, Color(height_normalized, 0, 0))
