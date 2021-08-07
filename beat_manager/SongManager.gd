extends Node


signal beat_hit
signal beat
signal target_selected
signal bar_selected
signal song_completed

export (Resource) var song

var _time_begin
var _time_delay
var _play_on_next_beat = false

onready var _audio_player = $AudioStreamPlayer


func _ready() -> void:
	set_process(false)
	yield(get_tree().create_timer(4.0), "timeout")
	song.reset();
	song.connect("beat", self, "_on_beat")
	song.connect("beat_hit", self, "_on_beat_hit")
	song.connect("target_selected", self, "_on_target_selected")
	song.connect("bar_selected", self, "_on_bar_selected")
	song.connect("song_completed", self, "_on_song_completed")
	_time_begin = OS.get_ticks_usec()
	_time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	set_process(true)


func _process(delta: float) -> void:
	var time = (OS.get_ticks_usec() - _time_begin) / 1_000_000.0
	time -= _time_delay
	time = max(0, time)

	song.update_time(time)


func _on_beat(audio_stream: AudioStream) -> void:
	emit_signal("beat")
	if _play_on_next_beat:
		_audio_player.stream = audio_stream
		_audio_player.play()
	_play_on_next_beat = false


func _on_beat_hit(input_delay: float) -> void:
	emit_signal("beat_hit", input_delay)


func _on_target_selected(time_remaining: float, cur_target_time: float, next_target_time: float) -> void:
	emit_signal("target_selected", time_remaining, cur_target_time, next_target_time)


func _on_bar_selected(bar: PoolRealArray, bar_duration: float, first_note_offset: float) -> void:
	emit_signal("bar_selected", bar, bar_duration, first_note_offset)
	_play_on_next_beat = true


func _on_song_completed() -> void:
	emit_signal("song_completed")
#	set_process(false)
#	yield(get_tree(), "idle_frame")
	song.reset()
	_time_begin = OS.get_ticks_usec()
	_time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
#	set_process(true)
