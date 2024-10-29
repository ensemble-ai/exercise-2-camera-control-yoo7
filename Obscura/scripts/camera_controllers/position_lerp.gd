class_name PositionLerp
extends CameraControllerBase


@export var follow_speed:float  # To be used as a ratio of the player's current speed
@export var catchup_speed:float
@export var leash_distance:float
@export var box_width:float = 10.0
@export var box_height:float = 10.0

var SNAP_DISTANCE := 0.1

func _ready() -> void:
	super()
	draw_camera_logic = true
	global_position = target.global_position
	

func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()

	var x_dir = 1 if target.position.x > position.x else -1
	var z_dir = 1 if target.position.z > position.z else -1
	var x_distance:float = abs(target.position.x - position.x)
	var z_distance:float = abs(target.position.z - position.z)
	
	if x_distance <= SNAP_DISTANCE:
		position.x = target.position.x
		x_dir = 0
	
	if z_distance <= SNAP_DISTANCE:
		position.z = target.position.z
		z_dir = 0
	
	var speed := follow_speed * target.speed

	if target.velocity.is_zero_approx():
		speed = catchup_speed * target.BASE_SPEED

	var velocity := Vector3(0.0, 0.0, 0.0)
	
	if x_distance >= leash_distance:
		velocity.x = target.velocity.x if target.velocity.x != 0 else x_dir * target.speed
	else:
		velocity.x = x_dir * speed
	
	if z_distance >= leash_distance:
		velocity.z = target.velocity.z if target.velocity.z != 0 else z_dir * target.speed
	else:
		velocity.z = z_dir * speed
	
	global_position.x += velocity.x * delta
	global_position.z += velocity.z * delta

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
