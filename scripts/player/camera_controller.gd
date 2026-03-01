extends Camera3D

@export var follow_speed = 0.1

@onready var player = get_parent().get_node("TestPlayer")


func _physics_process(delta):
	position = position.lerp(player.position + Vector3(0,12,0), 1- pow(follow_speed, delta))
	print(player.position)
