extends Node


signal beat_hit
signal beat
signal target_selected
signal bar_selected

export (Resource) var song


var time_begin
var time_delay


func _ready() -> void:
	time_begin = OS.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	song.connect("beat", self, "_on_beat")
	song.connect("beat_hit", self, "_on_beat_hit")
	song.connect("target_selected", self, "_on_target_selected")
	song.connect("bar_selected", self, "_on_bar_selected")


func _process(delta: float) -> void:
	var time = (OS.get_ticks_usec() - time_begin) / 1000000.0
	time -= time_delay
	time = max(0, time)

	song.update_time(time)


func _on_beat() -> void:
	emit_signal("beat")


func _on_beat_hit(input_delay: float) -> void:
	emit_signal("beat_hit", input_delay)


func _on_target_selected(time_remaining: float) -> void:
	emit_signal("target_selected", time_remaining)


func _on_bar_selected(bar: PoolRealArray, beat: float) -> void:
	emit_signal("bar_selected", bar, beat)
