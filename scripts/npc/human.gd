extends CharacterBody3D

@export var movement_speed: float = 4.0
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")

var region : NavigationRegion3D
var player 

var target : Vector3

var MAP_SIZE

# State stuff (this could be split into a seperate state machine but i am lazy)
enum ManagerStates {Wander, Concern, Panic, Dead}
@export var CurrentState : ManagerStates = ManagerStates.Wander
# Wander - Randomly Walk Around
# Concern - Stop and look toward whatever chaos is going on, then after a while slowly walk away in the other direction.
# Panic - Actively trying to run away from whatever is attacking

# Wander stuff
const MIN_WAIT_FRAMES = 100
const MAX_WAIT_FRAMES = 200
var WAIT_FRAMES = MAX_WAIT_FRAMES

# hack because godot navmesh is garbage and doesn't set is_finished 
var idle_frames : int = 0 
var old_pos : Vector3

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	
	# BAD PRACTICE! this creates a hard dependency.. but like.. dude cmon
	region = get_parent().get_node("NavigationRegion3D")
	player = get_parent().get_node("TestPlayer")
	
	MAP_SIZE = region.get_bounds().size
	
	
func set_movement_target(movement_target: Vector3):
	target = movement_target
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta: float) -> void:
	if CurrentState == ManagerStates.Wander:
		wander_physics_process(delta)
	elif CurrentState == ManagerStates.Panic:
		panic_physics_process(delta)
	elif CurrentState == ManagerStates.Concern:
		concern_physics_process(delta)
		
	choose_debug_mesh(CurrentState)

func wander_physics_process(delta):
	var danger_position : Vector3 = player.position
	
	# check if navmesh is initialized
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if idle_frames > WAIT_FRAMES:
		idle_frames = 0
		set_movement_target(get_random_point_on_navmesh())
		WAIT_FRAMES = randi_range(MIN_WAIT_FRAMES, MAX_WAIT_FRAMES)
		movement_speed = randf_range(2, 4)
		return
	
	physics_movement(delta)
	
	if danger_position.distance_to(position) < 6:
		set_movement_target(position)
		CurrentState = ManagerStates.Concern 
	
func concern_physics_process(delta):
	var danger_position : Vector3 = player.position
	var move_dir = position.direction_to(danger_position)
	
	navigation_agent.set_velocity(Vector3.ZERO)
	
	# Rotate only if moving
	if move_dir.length() > 0.001:
		var target_rot = atan2(move_dir.x, move_dir.z)
		rotation.y = lerp_angle(rotation.y, target_rot, delta * 8.0)
		
	if position.distance_to(danger_position) < 3:
		CurrentState = ManagerStates.Panic
		
	if position.distance_to(danger_position) > 7:
		CurrentState = ManagerStates.Wander
		
func panic_physics_process(delta):
	# try your best to run in the opposite direction from the danger, if you get far enough go back to wander.
	# for now it is going to be in a straight line
	var danger_position : Vector3 = player.position
	WAIT_FRAMES = 15
	
	# check if navmesh is initialized
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if idle_frames > WAIT_FRAMES:
		idle_frames = 0
		set_movement_target(position)
		return
		
	physics_movement(delta)
		
	if position.distance_to(danger_position) > 20:
		CurrentState = ManagerStates.Wander
		
	# if we get close enough to the next path then just new path to avoid stopping
	if position.distance_squared_to(target) < 3:
		set_movement_target(position + (danger_position.direction_to(position) * randf_range(1, 3)))
		
func physics_movement(delta):
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	
	var move_dir = (next_path_position - global_transform.origin).normalized()
	
	# Rotate only if moving
	if move_dir.length() > 0.001:
		var target_rot = atan2(move_dir.x, move_dir.z)
		rotation.y = lerp_angle(rotation.y, target_rot, delta * 8.0)
	
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
	
	if position.distance_squared_to(old_pos) < 0.1:
		idle_frames = idle_frames + 1
	else:
		idle_frames = 0
		old_pos = position

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()
	
func get_random_point_on_navmesh() -> Vector3:
	# Get the navigation map RID from the region
	var nav_map: RID = region.get_navigation_map()
	
	# Safety check
	if nav_map == RID():
		push_error("Navigation map not found.")
		return Vector3.ZERO
	
	# Get a random point directly from the navmesh
	# This is available in Godot 4.2+
	var random_point: Vector3 = NavigationServer3D.map_get_random_point(nav_map, 1, false)
	return random_point
	
func is_point_on_navmesh(point : Vector3) -> bool:
	return (NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, point).distance_squared_to(point) < 0.29)

func get_random_vector3_at_height(height, minimum, maximum):
	return Vector3(randf_range(minimum, maximum), height, randf_range(minimum, maximum))
	
func choose_debug_mesh(state):
	$WanderMesh.visible = state == ManagerStates.Wander
	$ConcernMesh.visible = state == ManagerStates.Concern
	$PanicMesh.visible = state == ManagerStates.Panic
	$DeadMesh.visible = state == ManagerStates.Dead
