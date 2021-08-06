extends Resource
class_name Song


signal beat_hit
signal beat
signal target_selected
signal bar_selected


var _prev_deviation = 0.0
var _cur_bar_index = 0
var _cur_note_index = 0
var _cur_target_time = 0.0
var _next_split_time = 0.0

export (float) var beat = 1.0
export (Dictionary) var bars
export (PoolIntArray) var song


func _ready() -> void:
	_next_target()


func _next_target() -> void:
	if _cur_note_index == 0:
		emit_signal("bar_selected", bars[song[_cur_bar_index]], beat)
	var cur_bar: PoolRealArray = bars[song[_cur_bar_index]]
	var next_bar_index = _cur_bar_index
	var next_note_index = _cur_note_index + 1
	if next_note_index >= cur_bar.size():
		next_note_index = 0
		next_bar_index += 1
	if next_bar_index >= song.size():
		print("reached end of song!")
		_cur_bar_index = 0
		_cur_note_index = 0
		return
			
	
	var next_bar: PoolRealArray = bars[song[next_bar_index]]
	var cur_note = _cur_bar_index * beat + cur_bar[_cur_note_index] * beat
	var next_note = next_bar_index * beat + next_bar[next_note_index] * beat
	_cur_target_time = cur_note
	_next_split_time = cur_note + (next_note - cur_note) / 2.0
	_cur_bar_index = next_bar_index
	_cur_note_index = next_note_index
	print("updated next split time to %s, target to %s" % [_next_split_time, _cur_target_time])
	

func update_time(time: float) -> void:
	if time >= _next_split_time:
		_next_target()
		var duration_to_next_split = _next_split_time - time
		print("duration to next split %s " % duration_to_next_split)
		emit_signal("target_selected", duration_to_next_split)
	
	# leave one bar for intro
	if _cur_bar_index < 1:
		return

	var deviation = time - _cur_target_time
	if _prev_deviation < 0 and deviation >= 0:
		emit_signal("beat")

	_prev_deviation = deviation

	if Input.is_action_just_pressed("beat_input"):
		var input_delay = deviation

		if deviation > beat / 2:
			input_delay = beat - deviation

		emit_signal("beat_hit", input_delay)
