extends Node


signal beat_hit
signal beat
signal beat_clock
signal target_selected
signal bar_selected
signal started

export (Resource) var song

var _time_begin
var _time_delay
var _play_on_next_beat = false
var _beat_clock_num = 0
var _beat_clock_duration = 0.0

onready var _audio_player = $AudioStreamPlayer


func _ready() -> void:
	_time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	_time_begin = OS.get_ticks_usec()
	_audio_player.play()
	set_process(false)
	_beat_clock_duration = 60.0 / song.beats_per_minute
	yield(self, "started")
	song.reset();
	song.connect("beat", self, "_on_beat")
	song.connect("beat_hit", self, "_on_beat_hit")
	song.connect("target_selected", self, "_on_target_selected")
	song.connect("bar_selected", self, "_on_bar_selected")
	_time_begin = OS.get_ticks_usec()
	set_process(true)


func _physics_process(_delta: float) -> void:
	var time = (OS.get_ticks_usec() - _time_begin) / 1_000_000.0
	time -= _time_delay
	time = max(0, time)
	if time >= 8.0:
		emit_signal("started", song.beats_per_minute)
		set_physics_process(false)


func _process(_delta: float) -> void:
	var time = (OS.get_ticks_usec() - _time_begin) / 1_000_000.0
	time -= _time_delay
	time = max(0, time)
	if time > _beat_clock_num * _beat_clock_duration:
		_beat_clock_num += 1
		emit_signal("beat_clock")
	song.update_time(time)


func _on_beat(_audio_stream: AudioStream) -> void:
	emit_signal("beat")
#	if _play_on_next_beat:
#		_audio_player.stream = audio_stream
#		_audio_player.play()
	_play_on_next_beat = false


func _on_beat_hit(input_delay: float, beat_index: int, action: String) -> void:
	emit_signal("beat_hit", input_delay, beat_index, action)


func _on_target_selected(time_remaining: float) -> void:
	emit_signal("target_selected", time_remaining)


func _on_bar_selected(bar: PoolRealArray) -> void:
	emit_signal("bar_selected", bar)
	_play_on_next_beat = true
