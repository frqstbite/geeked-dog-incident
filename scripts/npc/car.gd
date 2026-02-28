extends Area3D

var start_position
@export var travel_distance : float = 100.0
@export var speed = 0.003 
var end_position


var t : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = position
	end_position = start_position + (transform.basis.z * travel_distance)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	t += 0.003
	position = start_position.lerp(end_position, t)
	
	if(t > 1.0):
		t = 0
