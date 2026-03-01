extends Node

var original_geek_value : float = 100.0
var geek_value = original_geek_value
var geek_decay : float = 0.01

var amount_refilled : float = 0 # this is a stupid way to do it but it makes it easy to keep geek decay

var time_elapsed : float = 0.0

const E = exp(1)

func _process(delta: float) -> void:
	if geek_value > 0:
		geek_value = lerpf(original_geek_value, 0, time_elapsed) + amount_refilled
	if geek_value <= 0:
		kill_player()
	
	time_elapsed += delta * geek_decay
	
	geek_decay = (0.01) * (pow(E, time_elapsed))

func refill_geek(amount):
	amount_refilled += amount

func kill_player():
	time_elapsed = 0
	geek_value = original_geek_value
	amount_refilled = 0
	#get_tree().reload_current_scene.call_deferred()
