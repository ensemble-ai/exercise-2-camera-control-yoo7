class_name FourWaySpeedupPushZone
extends CameraControllerBase

@export var push_ratio:float
@export var pushbox_top_left:Vector2
@export var pushbox_bottom_right:Vector2
@export var speedup_zone_top_left:Vector2
@export var speedup_zone_bottom_right:Vector2


func _ready() -> void:
	super()
	draw_camera_logic = true
	global_position = target.global_position


func _process(delta: float) -> void:
	if !current:
		return

	if draw_camera_logic:
		draw_logic()

	var tpos := target.global_position
	var tleft := tpos.x + target.WIDTH / 2.0
	var tright := tpos.x - target.WIDTH / 2.0
	var ttop := tpos.z - target.HEIGHT / 2.0
	var tbottom := tpos.z + target.HEIGHT / 2.0
	var pushbox_left := global_position.x + pushbox_top_left.x
	var pushbox_right := global_position.x + pushbox_bottom_right.x
	var pushbox_top := global_position.z + pushbox_top_left.y
	var pushbox_bottom := global_position.z + pushbox_bottom_right.y
	var speedup_left := global_position.x + speedup_zone_top_left.x
	var speedup_right := global_position.x + speedup_zone_bottom_right.x
	var speedup_top := global_position.z + speedup_zone_top_left.y
	var speedup_bottom := global_position.z + speedup_zone_bottom_right.y

	# Boundary checks
	#region
	# Vessel is beyond speedup zone's left boundary and moving left
	if tleft < speedup_left and tleft < pushbox_left and target.velocity.x < 0:
		global_position.x += target.velocity.x * delta
	
	# Vessel is beyond speedup zone's right boundary and moving right
	if tright > speedup_right and tright > pushbox_right and target.velocity.x > 0:
		global_position.x += target.velocity.x * delta

	# Beyond speedup zone's top boundary and moving up
	if ttop > speedup_top and ttop > pushbox_top and target.velocity.z > 0:
		global_position.z += target.velocity.z * delta

	# Beyond speedup zone's bottom boundary and moving down
	if tbottom < speedup_bottom and tbottom < pushbox_bottom and target.velocity.z < 0:
		global_position.z += target.velocity.z * delta
	#endregion

	#region
	# Vessel is inside the left or right side of the push zone 
	if (
		(tpos.x < pushbox_left and tpos.x > speedup_left) 
		or (tpos.x > pushbox_right and tpos.x < speedup_right)
	):
		global_position.x += push_ratio * target.velocity.x * delta
		
	# Vessel is inside the top or bottom side of the push zone
	if (
		(tpos.z > pushbox_top and tpos.z < speedup_top) 
		or (tpos.z < pushbox_bottom and tpos.z > speedup_bottom)
	):
		global_position.z += push_ratio * target.velocity.z * delta
	#endregion

	super(delta)


func draw_logic() -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	var pushbox_left := pushbox_top_left.x
	var pushbox_right := pushbox_bottom_right.x
	var pushbox_top := pushbox_top_left.y
	var pushbox_bottom := pushbox_bottom_right.y
	var speedup_left := speedup_zone_top_left.x
	var speedup_right := speedup_zone_bottom_right.x
	var speedup_top := speedup_zone_top_left.y
	var speedup_bottom := speedup_zone_bottom_right.y
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(pushbox_right, 0, pushbox_top))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_right, 0, pushbox_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_right, 0, pushbox_bottom))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_left, 0, pushbox_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_left, 0, pushbox_bottom))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_left, 0, pushbox_top))
	
	immediate_mesh.surface_add_vertex(Vector3(pushbox_left, 0, pushbox_top))
	immediate_mesh.surface_add_vertex(Vector3(pushbox_right, 0, pushbox_top))
	immediate_mesh.surface_end()
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(Vector3(speedup_right, 0, speedup_top))
	immediate_mesh.surface_add_vertex(Vector3(speedup_right, 0, speedup_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_right, 0, speedup_bottom))
	immediate_mesh.surface_add_vertex(Vector3(speedup_left, 0, speedup_bottom))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_left, 0, speedup_bottom))
	immediate_mesh.surface_add_vertex(Vector3(speedup_left, 0, speedup_top))
	
	immediate_mesh.surface_add_vertex(Vector3(speedup_left, 0, speedup_top))
	immediate_mesh.surface_add_vertex(Vector3(speedup_right, 0, speedup_top))
	immediate_mesh.surface_end()

	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.BLACK
	
	add_child(mesh_instance)
	mesh_instance.global_transform = Transform3D.IDENTITY
	mesh_instance.global_position = Vector3(global_position.x, target.global_position.y, global_position.z)
	
	#mesh is freed after one update of _process
	await get_tree().process_frame
	mesh_instance.queue_free()
