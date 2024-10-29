class_name LerpFocus
extends CameraControllerBase


@export var lead_speed:float # To be used as a ratio of the player's current speed
@export var catchup_delay_duration:float
@export var catchup_speed:float
@export var leash_distance:float
@export var box_width:float = 10.0
@export var box_height:float = 10.0

var SNAP_DISTANCE := 0.5
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
	var x_distance:float = abs(target.position.x - position.x)
	var z_distance:float = abs(target.position.z - position.z)

	if x_distance <= SNAP_DISTANCE:
		position.x = target.position.x
		x_dir = 0
	else:
		x_dir = 1 if target.velocity.x > 0 else -1

	if z_distance <= SNAP_DISTANCE:
		position.z = target.position.z
		z_dir = 0
	else:
		z_dir = 1 if target.velocity.z > 0 else -1
	
	# Done catching up -- the camera is aligned with vessel!
	#if x_dir == 0 and z_dir == 0:
		#_pause_timer()
	#elif _timer != null and (target.velocity.x != 0 or target.velocity.z != 0):
		## Vessel began moving before catchup delay duration timer was up, so ignore timer
		## TODO  
		#print("WE ARE MOVING EARLY!!!")
		#_timer.stop()
		#_timer = null

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
		print("Catching up...")
		speed = catchup_speed * target.BASE_SPEED

		if x_dir != 0:
				x_dir = 1 if target.position.x > position.x else -1
			
		if z_dir != 0:
			z_dir = 1 if target.position.z > position.z else -1
		#if _timer == null and (target.position.x != position.x or target.position.z != position.z):			
			#print("Starting timer...")
			#_timer = Timer.new()
			#add_child(_timer)
			#_timer.one_shot = true
			#
			#_timer.start(catchup_delay_duration)
#
		## Start catching up
		#if _timer != null and _timer.is_stopped():
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
			#x_dir = 0
			#z_dir = 0

	if x_dir != 0 or z_dir != 0:
		_timer = null

	# Slow down a bit
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

# TODO
func _distance(from: Vector3, to: Vector3) -> float:
	return sqrt(pow(to.x - from.x, 2) + pow(to.z - from.z, 2))

func _pause_timer() -> void:
	if _timer != null:
		_timer.paused = true

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
