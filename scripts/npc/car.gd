extends RigidBody3D

var start_pos
@export var travel_distance : float = 100.0
var target_pos
var duration = 5.0 # Total seconds to take
var elapsed_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pos = position
	target_pos = start_pos + (transform.basis.z * travel_distance)


func _process(delta):
	elapsed_time += delta
	# Calculate normalized time (0 to 1)
	var t = clamp(elapsed_time / duration, 0.0, 1.0)
	
	# Linearly interpolate
	position = lerp(start_pos, target_pos, t)
	
	if t == 1:
		elapsed_time = 0
		

func _on_body_entered(body: Node) -> void:
	if body is Human: 
		if body.CurrentState != Human.ManagerStates.Dead:
			body.kill_human()
	elif body is Player:
		body.kill_player()
		#RoundManager.kill_player()
