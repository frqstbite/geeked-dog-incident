extends CharacterBody3D
class_name Player

var original_speed = 5.0
var speed = original_speed

var speed_modifiers : Array[SpeedModifier] = []

@export var attack_delay = 120 # physics frames
@onready var attack_area : Area3D = $Body/AttackArea
var attack_debounce = 0

# rotation
@export var rotation_speed = 2
var last_direction = Vector3.FORWARD

@onready var playerModel = $Body

@onready var cam = $Camera3D

func _ready():
	pass

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
		last_direction = direction
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	if direction:
		playerModel.rotation.y = lerp_angle(playerModel.rotation.y, atan2(-velocity.x, -velocity.z), 12.0 * delta)
	
	move_and_slide()
	
	# handle hitting
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if attack_debounce <= 0:
			var body_list = attack_area.get_overlapping_bodies()
			if body_list.size() > 0:
				for body in body_list:
					if body is Human:
						body.kill_human()
	
	
	
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
