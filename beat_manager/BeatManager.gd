tool
extends Node2D

var _hit_indicators = []

onready var _tween = $Tween
onready var _indicator = $BeatIndicator
onready var _screen_size = get_viewport().size
onready var _hit_indicator_scene = preload("res://beat_manager/hit_indicator/HitIndicator.tscn")

func _ready() -> void:
	if not Engine.editor_hint:
		for i in 10:
			var hit_indicator = _hit_indicator_scene.instance()
			_hit_indicators.append(hit_indicator)
			add_child(hit_indicator)
			hit_indicator.position.x = -1000
			hit_indicator.position.y = _screen_size.y / 2.0

func _get_configuration_warning() -> String:
	if not $SongManager.song is Song:
		return "Song manager must have a valid song"
	return ""


func _on_SongManager_beat() -> void:
	print("beat")
	_tween.interpolate_property(_indicator, "modulate", Color.greenyellow, Color.white, 0.5)


func _on_SongManager_beat_hit(input_delay: float) -> void:
	print("beat hit %s" % input_delay)


func _on_SongManager_target_selected(time_remaining: float) -> void:
	_tween.start()


func _move_indicator(x: float) -> void:
	_indicator.position.x = x


func _on_SongManager_bar_selected(bar: PoolRealArray, beat: float) -> void:
	_tween.interpolate_method(self, "_move_indicator", 0, _screen_size.x, beat)
	_tween.start()
	var offset = (1.0 - bar[bar.size() - 1]) / 2.0
	for i in _hit_indicators.size():
		if i < bar.size():
			_hit_indicators[i].position.x = _screen_size.x * offset + bar[i] * _screen_size.x
		else:
			_hit_indicators[i].position.x = -1000

