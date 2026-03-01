extends CharacterBody3D

@export var speed = 3
@export var friction = 0.02
@export var acceleration = 0.01

func get_input():
	var input = Vector2()
	if Input.is_action_pressed('right'):
		input.x += 1
	if Input.is_action_pressed('left'):
		input.x -= 1
	if Input.is_action_pressed('down'):
		input.y += 1
	if Input.is_action_pressed('up'):
		input.y -= 1
	return input

func get_mouse_3d_position() -> Vector3:
	var viewport = get_viewport()
	var camera = viewport.get_camera_3d()
	var mouse_pos = viewport.get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	var ray_end = ray_origin + ray_direction * camera.far

	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)
	if not result.is_empty():
		return result["position"]
	else:
		# Fallback to ray end if no intersection
		return ray_end

func _physics_process(delta):
	# Apply movement
	var direction = get_input()
	if direction.length() > 0:
		velocity = velocity.lerp(Vector3(direction.normalized().x,0,direction.normalized().y) * speed,1 - pow(acceleration,delta))
	else:
		velocity = velocity.lerp(Vector3.ZERO,1-pow( friction,delta))
	# Look at mouse position
	var mouse_position = get_mouse_3d_position()
	look_at(mouse_position)
	rotation.x = 0
	rotation.z = 0
	velocity += get_gravity() * delta
	move_and_slide()
