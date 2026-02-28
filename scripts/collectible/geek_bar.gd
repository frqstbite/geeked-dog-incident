extends Node3D
class_name GeekBar

var player : Player

@export var geek_refill_factor = 10.0

@export_category("Modifier")
@export var modifier : bool = false
@export var speed : float = 10.0
@export var duration : float = 10.0 

func on_consume():
	if player:
		if modifier:
			player.create_speed_modifier(speed, duration)
			RoundManager.refill_geek(geek_refill_factor)
		
func _on_body_entered(body: Node) -> void:
	if body is Player:
		player = body
		on_consume()
		queue_free()
