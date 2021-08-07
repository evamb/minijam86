tool
extends Node2D

var _hit_indicators = []
var _hit_indicator_index = 0

onready var _tween = $Tween
onready var _indicator = $BeatIndicator
onready var _screen_size = get_viewport().size
onready var _hit_indicator_scene = preload("res://beat_manager/hit_indicator/HitIndicator.tscn")

func _ready() -> void:
	if not Engine.editor_hint:
		_indicator.position.x = _screen_size.x * 0.5
		for i in 10:
			var hit_indicator = _hit_indicator_scene.instance()
			_hit_indicators.append(hit_indicator)
			_indicator.add_child(hit_indicator)
			hit_indicator.position.x = -1000


func _get_configuration_warning() -> String:
	if not $SongManager.song is Song:
		return "Song manager must have a valid song"
	return ""


func _on_SongManager_beat() -> void:
	print("beat")
	_tween.interpolate_method(self, "_highlight_indicator", Color.greenyellow, Color.white, 0.5)
	_tween.start()


func _on_SongManager_beat_hit(input_delay: float) -> void:
	print("beat hit %s" % input_delay)


func _on_SongManager_target_selected(time_remaining: float, cur_target_time: float, next_target_time: float) -> void:
	var cur_index = (_hit_indicator_index + 1) % _hit_indicators.size()
	var next_index = (_hit_indicator_index + 2) % _hit_indicators.size()
	var cur_target_pos = cur_target_time * _screen_size.x
	var next_target_pos = next_target_time * _screen_size.x
	print("updating target positions: %s, %s" % [cur_target_pos, next_target_pos])
	_hit_indicators[cur_index].position.x = cur_target_pos
	_hit_indicators[next_index].position.x = next_target_pos
	_hit_indicator_index = cur_index


func _move_indicator(x: float) -> void:
	_indicator.position.x = x


func _show_indicator(a: float) -> void:
	_indicator.modulate.a = a


func _highlight_indicator(c: Color) -> void:
	_indicator.modulate.r = c.r
	_indicator.modulate.g = c.g
	_indicator.modulate.b = c.b


func _on_SongManager_bar_selected(bar: PoolRealArray, bar_duration: float, first_note_offset: float) -> void:
#	_indicator.set_speed(_screen_size.x)
	
	pass
#	var tween_duration = bar_duration - bar_duration * first_note_offset * 2
#	if first_note_offset > 0:
#		_tween.interpolate_method(self, "_show_indicator", 0, 1, tween_duration)
#	_tween.interpolate_method(self, "_move_indicator", first_note_offset * _screen_size.x, _screen_size.x, tween_duration)
#	_tween.start()
#	var offset = (1.0 - bar[bar.size() - 1]) / 2.0
#	print("new bar with offset %s, note offset: %s" % [offset, first_note_offset])
#	for i in _hit_indicators.size():
#		if i < bar.size():
#			_hit_indicators[i].position.x = _screen_size.x * offset + bar[i] * _screen_size.x
#		else:
#			_hit_indicators[i].position.x = -1000

