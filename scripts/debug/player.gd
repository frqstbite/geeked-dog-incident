extends CharacterBody3D
class_name Player

var original_speed = 5.0
var speed = original_speed

var speed_modifiers : Array[SpeedModifier] = []

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	calculate_speed(delta)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
func create_speed_modifier(s : float, d : float):
	var modifier = SpeedModifier.new()
	modifier.speed = s
	modifier.duration = d
	speed_modifiers.append(modifier)
	
func calculate_speed(delta):
	if speed_modifiers.size() == 0:
		speed = original_speed
		return
	
	# average out the speed of all the modifiers 
	var total_speed = 0
	
	for modifier in speed_modifiers:
		total_speed += modifier.speed
		total_speed /= speed_modifiers.size()
	
	speed = total_speed
	
	for i in range(speed_modifiers.size() - 1, -1, -1):
		speed_modifiers[i].duration -= delta
		if speed_modifiers[i].duration <= 0:
			speed_modifiers.remove_at(i)
