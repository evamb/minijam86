extends Node


signal beat_hit
signal beat
signal target_selected
signal bar_selected
signal song_completed
signal offset_updated
signal started

export (Resource) var song

var _time_begin
var _time_delay
var _play_on_next_beat = false

onready var _audio_player = $AudioStreamPlayer


func _ready() -> void:
	set_process(false)
	yield(self, "started")
	song.reset();
	song.connect("beat", self, "_on_beat")
	song.connect("beat_hit", self, "_on_beat_hit")
	song.connect("target_selected", self, "_on_target_selected")
	song.connect("bar_selected", self, "_on_bar_selected")
	song.connect("song_completed", self, "_on_song_completed")
	song.connect("offset_updated", self, "_on_offset_updated")
	_time_begin = OS.get_ticks_usec()
	_time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	set_process(true)


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("beat_input"):
		emit_signal("started")


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


func _on_beat_hit(input_delay: float, beat_index: int) -> void:
	emit_signal("beat_hit", input_delay, beat_index)


func _on_target_selected(time_remaining: float) -> void:
	emit_signal("target_selected", time_remaining)


func _on_bar_selected(bar: PoolRealArray) -> void:
	emit_signal("bar_selected", bar)
	_play_on_next_beat = true


func _on_song_completed() -> void:
	emit_signal("song_completed")
#	set_process(false)
#	yield(get_tree(), "idle_frame")
	song.reset()
	_time_begin = OS.get_ticks_usec()
	_time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
#	set_process(true)


func _on_offset_updated(time: float) -> void:
	emit_signal("offset_updated", time)
