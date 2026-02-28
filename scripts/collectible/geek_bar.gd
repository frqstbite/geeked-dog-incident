extends Node3D
class_name GeekBar

var player : Player

func on_consume():
	if player:
		player.create_speed_modifier(10.0, 10.0)

func _on_body_entered(body: Node) -> void:
	if body is Player:
		player = body
		on_consume()
		queue_free()
