class_name LerpFocus
extends CameraControllerBase


@export var lead_speed:float # To be used as a ratio of the player's current speed
@export var catchup_delay_duration:float
@export var catchup_speed:float
@export var leash_distance:float
@export var box_width:float = 10.0
@export var box_height:float = 10.0

var SNAP_DISTANCE := 0.4
var _timer:Timer = null


func _ready() -> void:
	super()
	draw_camera_logic = true
	global_position = target.global_position
	

func _process(delta: float) -> void:
	if !current:
		return
	
	if draw_camera_logic:
		draw_logic()

	var x_dir:int
	var z_dir:int
	
	if abs(target.position.x - position.x) <= SNAP_DISTANCE:
		position.x = target.position.x
		x_dir = 0
		print("snapping x")
		#_deactivate_timer()
	else:
		x_dir = 1 if target.velocity.x > 0 else -1
	
	if abs(target.position.z - position.z) <= SNAP_DISTANCE:
		position.z = target.position.z
		z_dir = 0
		print("snapping z")
		#_deactivate_timer()
	else:
		z_dir = 1 if target.velocity.z > 0 else -1
	
	# Vessel began moving before catchup delay duration timer was up, so ignore timer
	#if _timer != null and (target.velocity.x != 0 or target.velocity.z != 0):
		#_deactivate_timer()
		#print("stopping timer early")

	# Vessel is ahead but is still moving -- need to immediately match its position to not be behind
	# But also add SNAP_DISTANCE (in the correct direction) so that the camera isn't so close that it
	# snaps to vessel position (we want to be fully ahead of the vessel)
	if (
		position.x < target.position.x and target.velocity.x > 0
		or target.position.x < position.x and target.velocity.x < 0
	):
		position.x = target.position.x + (x_dir * SNAP_DISTANCE)
	
	if (
		position.z < target.position.z and target.velocity.z > 0
		or target.position.z < position.z and target.velocity.z < 0
	):
		position.z = target.position.z + (z_dir * SNAP_DISTANCE)

	var speed := lead_speed * target.speed

	# Stop being ahead of vessel, and turn back around back towards the vessel instead
	if target.velocity.is_zero_approx():
		speed = catchup_speed * target.BASE_SPEED

		if x_dir != 0:
			x_dir = 1 if target.position.x > position.x else -1
		
		if z_dir != 0:
			z_dir = 1 if target.position.z > position.z else -1
		#if _timer == null:
			#print("Starting timer...")
			#_timer = Timer.new()
			#add_child(_timer)
			#_timer.one_shot = true
			#
			#_timer.start(catchup_delay_duration)
#
		## Start catching up
		#if _timer.is_stopped():
			#print("Catching up...")
			#speed = catchup_speed * target.BASE_SPEED
#
			#if x_dir != 0:
				#x_dir = 1 if target.position.x > position.x else -1
			#
			#if z_dir != 0:
				#z_dir = 1 if target.position.z > position.z else -1
		#else: # Don't start catching up yet
			## TODO maybe just return early?
			##x_dir = 0
			##z_dir = 0
			#return

	# Slow down a bit
	if _distance(position, target.position) >= leash_distance:
		speed = target.speed

	global_position.x += x_dir * speed * delta
	global_position.z += z_dir * speed * delta

	super(delta)


func _distance(from: Vector3, to: Vector3) -> float:
	return sqrt(pow(to.x - from.x, 2) + pow(to.z - from.z, 2))

func _deactivate_timer() -> void:
	if _timer != null:
		_timer.stop()
		_timer = null

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
