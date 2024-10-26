class_name PositionLerp
extends CameraControllerBase


@export var follow_speed := target.BASE_SPEED * 0.8
@export var catchup_speed := target.BASE_SPEED
@export var leash_distance:float
@export var box_width:float = 10.0
@export var box_height:float = 10.0


func _ready() -> void:
	super()
	position = target.position
	

func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()

	var speed := follow_speed
	
	#TODO var direction = (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var x_diff = target.position.x - position.x
	var z_diff = target.position.z - position.z
	
	if _distance(position, target.position) >= leash_distance:
		speed = target.speed
	elif target.velocity.is_zero_approx():
		# Catch up if vessel is stopped
		speed = catchup_speed

	# Camera keeps moving according to autoscroll speed
	global_position.x += x_diff * speed * delta
	global_position.z += z_diff * speed * delta

	super(delta)


func _distance(from: Vector3, to: Vector3) -> float:
	return sqrt(pow(to.x - from.x, 2) + pow(to.y - from.y, 2))


func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var left:float = -box_width / 2
	var right:float = box_width / 2
	var top:float = -box_height / 2
	var bottom:float = box_height / 2
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(0, 0, top))
	immediate_mesh.surface_add_vertex(Vector3(0, 0, bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(right, 0, 0))
	immediate_mesh.surface_add_vertex(Vector3(left, 0, 0))
	
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
