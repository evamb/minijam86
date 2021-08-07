tool
extends Node2D

var _hit_indicators = []
var _hit_indicator_index = 0
var _indicator_width = 1000
var _note_index = 0
export(float) var _indicator_screen_percentage = 0.5

onready var _tween = $Tween
onready var _indicator = $BeatIndicator
onready var _screen_size = get_viewport().size
onready var _notes = $SongManager.song.get_notes()
onready var _bar_duration = 4.0 / ($SongManager.song.beats_per_minute / 60.0)
onready var HitIndicator = preload("res://beat_manager/hit_indicator/HitIndicator.tscn")

func _ready() -> void:
	_indicator_width = _screen_size.x * _indicator_screen_percentage
	if not Engine.editor_hint:
		_indicator.position.x = 0
		for i in min(10, _notes.size()):
			var hit_indicator = HitIndicator.instance()
			_hit_indicators.append(hit_indicator)
			_indicator.add_child(hit_indicator)
			hit_indicator.position.x = -1000
	_reset_indicators()


func _reset_indicators() -> void:
	for i in 5:
		var hit_indicator_pos = _notes[i] * _indicator_width * _bar_duration
		_hit_indicators[i].position.x = hit_indicator_pos
		_note_index = i
		_hit_indicator_index = i


func _get_configuration_warning() -> String:
	if not $SongManager.song is Song:
		return "Song manager must have a valid song"
	return ""


func _on_SongManager_beat() -> void:
	print("beat")


func _on_SongManager_beat_hit(input_delay: float) -> void:
	print("beat hit %s" % input_delay)


func _on_SongManager_target_selected(time_remaining: float, cur_target_time: float, next_target_time: float) -> void:
	var cur_index = (_hit_indicator_index + 1) % _hit_indicators.size()
	_note_index = (_note_index + 1) % _notes.size()
	_hit_indicators[cur_index].position.x = _notes[_note_index] * _indicator_width * _bar_duration
	_hit_indicator_index = cur_index


func _on_SongManager_bar_selected(bar: PoolRealArray, bar_duration: float, first_note_offset: float) -> void:
	_indicator.set_speed(_indicator_width)


func _on_SongManager_song_completed() -> void:
	_indicator.position.x = 0
	_reset_indicators()
