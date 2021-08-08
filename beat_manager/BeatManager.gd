extends Node2D

var _hit_indicators = []
var _hit_indicator_index = 0
var _indicator_width = 1000
var _note_index = 0
export(float) var _indicator_screen_percentage = 0.5

onready var _tween = $Tween
onready var _indicator = $BeatIndicator
onready var _screen_size = Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height"))
onready var _notes = $SongManager.song.get_notes()
onready var _hard_notes = $SongManager.song.get_notes(false)
onready var _bar_duration = 4.0 / ($SongManager.song.beats_per_minute / 60.0)
onready var HitIndicator = preload("res://beat_manager/hit_indicator/HitIndicator.tscn")

func _ready() -> void:
	_indicator_width = _screen_size.x * _indicator_screen_percentage
	_indicator.position.x = 0
	for i in min(15, _notes.size()):
		var hit_indicator = HitIndicator.instance()
		_hit_indicators.append(hit_indicator)
		_indicator.add_child(hit_indicator)
		hit_indicator.position.x = -2000
		if i < 5:
			var hit_indicator_pos = _notes[i] * _indicator_width * _bar_duration
			_hit_indicators[i].position.x = hit_indicator_pos
			_note_index = i
			_hit_indicator_index = i


func _on_SongManager_beat() -> void:
	print("beat")


func _on_SongManager_beat_hit(input_delay: float, beat_index: int, _action: String) -> void:
	_hit_indicators[beat_index % _hit_indicators.size()].frame =\
		2 if abs(input_delay) > Globals.MISS_THRESHOLD else 1 


func _on_SongManager_target_selected(_time_remaining: float) -> void:
	var cur_index = (_hit_indicator_index + 1) % _hit_indicators.size()
	_note_index += 1
	var easy_offset = 1 if _note_index >= _notes.size() else 0
	var hard_offset = max(0, (_note_index - _notes.size()) / _hard_notes.size())
	var note = _notes[_note_index % _notes.size()]
	if easy_offset > 0:
		note = _hard_notes[(_note_index - _notes.size()) % _hard_notes.size()]
	var offset = $SongManager.song.song.size() * (easy_offset + hard_offset)
	_hit_indicators[cur_index].position.x = _indicator_width * _bar_duration\
		* (offset + note)
	_hit_indicators[cur_index].frame = 0
	_hit_indicator_index = cur_index


func _on_SongManager_started(_bpm: float) -> void:
	_indicator.set_speed(_indicator_width)
