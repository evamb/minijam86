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
var _offset = 0.0
var _was_triggered = false
var _beat_index = 0

export (float) var beats_per_minute = 60.0
export (Array, AudioStream) var audio_streams
export (Array, PoolRealArray) var bars
export (PoolIntArray) var song


func reset() -> void:
	_bar_duration = 4.0 / (beats_per_minute / 60.0)
	_prev_deviation = -1.0
	_cur_bar_index = 0
	_cur_note_index = 0
	_cur_target_time = 0.0
	_next_split_time = 0.0
	_offset = 0.0


func get_notes(easy = true) -> PoolRealArray:
	var offsets = PoolRealArray()
	var bar_count = 0
	var diff_index_offset = 0 if easy else bars.size() / 2
	for bar_index in song:
		for note in bars[bar_index + diff_index_offset]:
			offsets.append(bar_count + note)
		bar_count += 1
	return offsets


func _next_target() -> void:
	_was_triggered = false
	var diff_index_offset = 0 if _offset <= 0 else bars.size() / 2
	var cur_bar = bars[song[_cur_bar_index] + diff_index_offset]
	if _cur_note_index == 0:
		emit_signal("bar_selected", cur_bar)
	var cur_note = _offset * _bar_duration + _cur_bar_index * _bar_duration\
		+ cur_bar[_cur_note_index] * _bar_duration
	_cur_target_time = cur_note
	
	var next_bar_index = _cur_bar_index
	var next_note_index = _cur_note_index + 1
	if next_note_index >= cur_bar.size():
		next_note_index = 0
		next_bar_index += 1
	
	if next_bar_index >= song.size():
		_offset += song.size()
		next_bar_index = 0
		
	var next_bar = bars[song[next_bar_index] + diff_index_offset]
	var next_note = _offset * _bar_duration + next_bar_index * _bar_duration\
		+ next_bar[next_note_index] * _bar_duration
	_next_split_time = cur_note + (next_note - cur_note) / 2.0
	_cur_bar_index = next_bar_index
	_cur_note_index = next_note_index


func update_time(time: float) -> void:
	if time >= _next_split_time:
		_next_target()
		_beat_index += 1
		var duration_to_next_split = _next_split_time - time
		emit_signal("target_selected", duration_to_next_split)
	
	var deviation = time - _cur_target_time
	if _prev_deviation < 0 and deviation >= 0:
		emit_signal("beat", audio_streams[song[_cur_bar_index]])

	_prev_deviation = deviation

	if Input.is_action_just_pressed("beat_input") and not _was_triggered:
		_was_triggered = true
		var input_delay = deviation

		if deviation > _bar_duration / 2:
			input_delay = _bar_duration - deviation
		var action = "arm_left"
		if Input.is_action_just_pressed("arm_right"):
			action = "arm_right"
		elif Input.is_action_just_pressed("leg_left"):
			action = "leg_left"
		elif Input.is_action_just_pressed("leg_right"):
			action = "leg_right"
		emit_signal("beat_hit", input_delay, _beat_index - 1, action)
