extends Resource
class_name Song


signal beat_hit
signal beat
signal target_selected
signal bar_selected


var _prev_deviation = -1.0
var _cur_bar_index = 0
var _cur_note_index = 0
var _cur_target_time = 0.0
var _next_split_time = 0.0
var _bar_duration = 0.0

export (float) var beats_per_minute = 60.0
export (Dictionary) var bars
export (PoolIntArray) var song


func ready() -> void:
	_bar_duration = 4.0 / (beats_per_minute / 60.0)


func _next_target() -> void:
	if _cur_note_index == 0:
		var first_note_offset = 0.125 if _cur_bar_index == 0 else 0
		emit_signal("bar_selected", bars[song[_cur_bar_index]], _bar_duration, first_note_offset)
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
	var cur_note = _cur_bar_index * _bar_duration + cur_bar[_cur_note_index] * _bar_duration
	var next_note = next_bar_index * _bar_duration + next_bar[next_note_index] * _bar_duration
	_cur_target_time = cur_note
	_next_split_time = cur_note + (next_note - cur_note) / 2.0
	_cur_bar_index = next_bar_index
	_cur_note_index = next_note_index
	

func update_time(time: float) -> void:
	if time >= _next_split_time:
		_next_target()
		var duration_to_next_split = _next_split_time - time
		emit_signal("target_selected", duration_to_next_split)
	
	var deviation = time - _cur_target_time
	if _prev_deviation < 0 and deviation >= 0:
		emit_signal("beat")

	_prev_deviation = deviation
	# leave one bar for intro
	if _cur_bar_index < 1:
		return



	if Input.is_action_just_pressed("beat_input"):
		var input_delay = deviation

		if deviation > _bar_duration / 2:
			input_delay = _bar_duration - deviation

		emit_signal("beat_hit", input_delay)