extends Node

var geek_value : float = 100.0
var geek_decay : float = 0.01

func _process(delta: float) -> void:
	if geek_value > 0:
		geek_value = lerpf(geek_value, 0, geek_decay * delta)
