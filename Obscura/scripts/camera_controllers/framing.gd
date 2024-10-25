class_name Framing
extends CameraControllerBase

@export var top_left := Vector2(-5, 5)
@export var bottom_right := Vector2(5, -5)
@export var autoscroll_speed := Vector3(10, 0, 4)

func _ready() -> void:
	super()
	position = target.position
	

func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()
	
	var x_movement := autoscroll_speed.x * delta
	var z_movement := autoscroll_speed.z * delta
	
	# Camera keeps moving according to autoscroll speed
	global_position.x += x_movement
	global_position.z += z_movement
	
	# Player is moving at least autoscroll speed even with no player input
	# Player input is like velocity relative to the box
	target.global_position.x += x_movement
	target.global_position.z += z_movement
	
	var tpos := target.global_position
	var left := global_position.x + top_left.x
	var right := global_position.x + bottom_right.x
	var top := global_position.z + top_left.y
	var bottom := global_position.z + bottom_right.y

	# Boundary checks
	# Vessel is beyond left boundary
	var diff_between_left_edges = (tpos.x - target.WIDTH / 2.0) - left
	if diff_between_left_edges < 0:
		target.global_position.x -= diff_between_left_edges
	# Vessel is beyond right boundary
	var diff_between_right_edges = (tpos.x + target.WIDTH / 2.0) - right
	if diff_between_right_edges > 0:
		target.global_position.x -= diff_between_right_edges
	# Top
	var diff_between_top_edges = (tpos.z + target.HEIGHT / 2.0) - top
	if diff_between_top_edges > 0:
		target.global_position.z -= diff_between_top_edges
	# Bottom
	var diff_between_bottom_edges = (tpos.z - target.HEIGHT / 2.0) - bottom
	if diff_between_bottom_edges < 0:
		target.global_position.z -= diff_between_bottom_edges

	super(delta)


func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var left := top_left.x
	var right := bottom_right.x
	var top := top_left.y
	var bottom := bottom_right.y
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, bottom))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	
	immediate_mesh.surface_add_vertex(Vector3(left, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(right, 0, top))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
