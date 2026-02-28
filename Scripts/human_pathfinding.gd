extends CharacterBody3D

@export var movement_speed: float = 4.0
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")

var target : Vector3

var MAP_SIZE

# State stuff (this could be split into a seperate state machine but i am lazy)
enum ManagerStates {Wander, Concern, Panic}
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
	var region : NavigationRegion3D = get_parent().get_node("NavigationRegion3D")
	MAP_SIZE = region.get_bounds().size
	
	set_movement_target(get_random_point_on_navmesh())
	
	
func set_movement_target(movement_target: Vector3):
	target = movement_target
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta: float) -> void:
	pass
	
	if CurrentState == ManagerStates.Wander:
		wander_physics_process(delta)
	elif CurrentState == ManagerStates.Panic:
		panic_physics_process(delta)

func wander_physics_process(_delta):
	# check if navmesh is initialized
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if idle_frames > WAIT_FRAMES:
		idle_frames = 0
		set_movement_target(get_random_point_on_navmesh())
		WAIT_FRAMES = randi_range(MIN_WAIT_FRAMES, MAX_WAIT_FRAMES)
		return

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
	
	if position.distance_squared_to(old_pos) < 0.1:
		idle_frames = idle_frames + 1
	else:
		idle_frames = 0
		old_pos = position
		
func panic_physics_process(_delta):
	# try your best to run in the opposite direction from the danger, if you get far enough go back to wander.
	# for now it is going to be in a straight line
	#var danger_position : Vector3 = Vector3.ZERO
	WAIT_FRAMES = 10
	
	# check if navmesh is initialized
	if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if idle_frames > WAIT_FRAMES:
		idle_frames = 0
		set_movement_target(position + (transform.basis.z * randf_range(3, 5)))
		return
		
	if !is_point_on_navmesh(position + (transform.basis.z * 4.0)):
		set_movement_target(get_random_point_on_navmesh())

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed
	
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
	
	if position.distance_squared_to(old_pos) < 0.1:
		idle_frames = idle_frames + 1
	else:
		idle_frames = 0
		old_pos = position
		
	# if we get close enough to the next path then just new path to avoid stopping
	if position.distance_squared_to(target) < 3:
		set_movement_target(position + (transform.basis.z * randf_range(3, 5)))

func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
	move_and_slide()
	
func get_random_point_on_navmesh() -> Vector3:
	return Vector3(randf_range(-MAP_SIZE.x / 2, MAP_SIZE.x / 2), 1, -randf_range(-MAP_SIZE.z / 2, MAP_SIZE.z / 2))
	
func is_point_on_navmesh(point : Vector3) -> bool:
	return (NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, point).distance_squared_to(point) < 0.29) 
