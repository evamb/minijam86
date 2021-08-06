extends Resource
class_name Song


signal beat_hit
signal beat


var prev_deviation = 0.0


export (float) var beat = 1.0
export (Dictionary) var bars
export (PoolIntArray) var song


func _ready() -> void:
	pass


func update_time(time: float) -> void:
	var deviation = fmod(time, beat)
	
	if deviation < prev_deviation:
		emit_signal("beat")
		
	prev_deviation = deviation

	if Input.is_action_just_pressed("beat_input"):
		var input_delay = deviation
		
		if deviation > beat / 2:
			input_delay = beat - deviation
		
		emit_signal("beat_hit", input_delay)
