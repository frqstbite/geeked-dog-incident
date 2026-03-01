extends Control

var has_attacked : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$TextureProgressBar.value = RoundManager.geek_value
	var time_elapsed = RoundManager.time_elapsed * 100
	var minutes = floor(time_elapsed / 60)
	var seconds = fmod(time_elapsed, 60)
	# this is stupid
	if seconds > 9:
		$TimeElapsed.text = str(int(minutes)) + ":" + str(int(ceil(seconds)))
	else:
		$TimeElapsed.text = str(int(minutes)) + ":0" + str(int(ceil(seconds)))
		
	if !has_attacked:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			$AttackLabel.queue_free()
			has_attacked = true
	
