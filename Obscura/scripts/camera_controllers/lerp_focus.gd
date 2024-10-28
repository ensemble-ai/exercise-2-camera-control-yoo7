class_name LerpFocus
extends CameraControllerBase


@export var lead_speed:float # To be used as a ratio of the player's current speed
@export var catchup_delay_duration:float
@export var catchup_speed:float
@export var leash_distance:float
@export var box_width:float = 10.0
@export var box_height:float = 10.0


func _ready() -> void:
	super()
	draw_camera_logic = true
	global_position = target.global_position
	

func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()

	
	
	var x_dir:float
	var z_dir:float
	var x_distance = abs(target.position.x - position.x)
	var z_distance = abs(target.position.z - position.z)
	
	var speed:float

	if target.velocity.is_zero_approx():
		speed = catchup_speed * target.BASE_SPEED
		# Stop moving ahead of vessel -- instead, go TOWARDS it
		# TODO timer with the catchup delay
		x_dir = 1 if target.position.x > position.x else -1
		z_dir = 1 if target.position.z > position.z else -1
	else:  # Travel in same direction as vessel
		speed = lead_speed * target.speed
		print("NEW SPEED %f" % speed)

		x_dir = 1 if target.velocity.x > 0 else -1
		z_dir = 1 if target.velocity.z > 0 else -1

		# Getting too ahead of vessel -- slow down a bit
		if _distance(position, target.position) >= leash_distance:
			print("leash!!!")
			speed = 0.0
			#speed = target.speed

	print("speed %f" % speed)
	print("distance %f" % _distance(position, target.position))

	# Camera moves in direction of target
	global_position.x += x_dir * x_distance * speed * delta
	global_position.z += z_dir * z_distance * speed * delta

	super(delta)


func _distance(from: Vector3, to: Vector3) -> float:
	return sqrt(pow(to.x - from.x, 2) + pow(to.z - from.z, 2))


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
