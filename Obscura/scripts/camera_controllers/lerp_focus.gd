class_name LerpFocus
extends CameraControllerBase

var SNAP_DISTANCE := 0.5
@export var lead_speed:float # To be used as a ratio of the player's current speed
@export var catchup_delay_duration:float
@export var catchup_speed:float
@export var leash_distance:float
@export var box_width:float = 10.0
@export var box_height:float = 10.0
var _timer:Timer = null
var _catching_up_active = false

# Some notes on _timer variable:
# When the vessel is not moving, there are 2 scenarios for the camera.
# (1) Wait catchup delay duration, then move towards vessel. 
#     - When waiting, timer is actively running (not paused or stopped)
#     - When timer is moving towards vessel to catch up, 
# (2) Camera is already aligned with vessel, which can happen if camera
#     finished catching up. Timer is PAUSED.
#     (We could probably just stop the timer, but then 

# The timer is STOPPED when the timer is up (so camera will start catching up)
# or if the vessel moved before the timer expired (the timer is then reset to NULL).

# The timer is RESET TO NULL when the vessel either:
# (1) started moving before the timer expired, or 
# (2) the vessel is moving and it's not because it's trying to catch up.
# i.e., the timer is reset to null when we're okay with a new timer being started
# or we're not in the middle of doing stuff related to catchup


func _ready() -> void:
	super()
	draw_camera_logic = true
	global_position = target.global_position


func _process(delta: float) -> void:
	if !current:
		return

	if draw_camera_logic:
		draw_logic()

	var x_dir:int  # Direction that camera should move in in x-direction
	var z_dir:int  # Direction that camera should move in in z-direction
	var x_distance:float = abs(target.position.x - position.x)
	var z_distance:float = abs(target.position.z - position.z)

	#region
	if x_distance <= SNAP_DISTANCE:
		# Close enough to target in x direction, so snap to the target's x position
		# No need to move camera in the x direction then, so x_dir = 0
		position.x = target.position.x
		x_dir = 0
	elif target.velocity.x > 0:
		x_dir = 1
	elif target.velocity.x < 0:
		x_dir = -1
	else:
		# Target is not moving, but camera is more than SNAP_DISTANCE away. Will have to catch up
		x_dir = 1 if target.position.x > position.x else -1

	# Same thing but z direction
	if z_distance <= SNAP_DISTANCE:
		position.z = target.position.z
		z_dir = 0
	elif target.velocity.z > 0:
		z_dir = 1
	elif target.velocity.z < 0:
		z_dir = -1
	else:
		z_dir = 1 if target.position.z > position.z else -1
	#endregion

	#region
	if x_dir == 0 and z_dir == 0:
		# We must be done catching up -- the camera is aligned with vessel!
		_pause_timer()
		_catching_up_active = false
	elif _timer != null and (target.velocity.x != 0 or target.velocity.z != 0):
		# Vessel began moving before catchup delay duration timer was up, so ignore timer
		_timer.stop()
		_timer = null
		_catching_up_active = false
	#endregion

	#region
	# Vessel is ahead but is still moving -- need to immediately match its position to not be behind
	# But also add SNAP_DISTANCE (in the correct direction) so that the camera is fully ahead of
	# vessel and also not so close that it snaps to vessel position
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
	#endregion

	#region
	# Adjust the speed and dir as needed depending on
	# whether the target is moving and the timer's status
	var speed := lead_speed * target.speed

	# Stop being ahead of vessel, and turn back around back towards the vessel instead
	if target.velocity.is_zero_approx():
		if _timer == null and (target.position.x != position.x or target.position.z != position.z):			
			_timer = Timer.new()
			add_child(_timer)
			_timer.one_shot = true
			
			_timer.start(catchup_delay_duration)

		if _timer != null:
			if not _timer.paused and not _timer.is_stopped():
				# Timer is actively running still -- don't move the camera!
				x_dir = 0
				z_dir = 0
			if _timer.is_stopped():
				_timer.paused = false
				_catching_up_active = true
				speed = catchup_speed * target.BASE_SPEED
	#endregion

	# If camera is moving and it's not because the camera is trying to catch up, 
	# then totally reset timer
	if (x_dir != 0 or z_dir != 0) and not _catching_up_active:
		_timer = null

	#region
	# Determine the velocity that camera should move in
	var velocity := Vector3(0.0, 0.0, 0.0)

	if x_distance >= leash_distance:
		# Camera is too far ahead, so move at vessel's velocity
		# But if vessel is not moving, we are trying to catch up
		velocity.x = target.velocity.x if target.velocity.x != 0 else x_dir * target.speed
	else:
		velocity.x = x_dir * speed
	
	# Same thing but z direction
	if z_distance >= leash_distance:
		velocity.z = target.velocity.z if target.velocity.z != 0 else z_dir * target.speed
	else:
		velocity.z = z_dir * speed
	#endregion
	
	# Actually update camera's position
	global_position.x += velocity.x * delta
	global_position.z += velocity.z * delta

	super(delta)


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
