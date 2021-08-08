extends Node2D


onready var _animated_sprite: AnimatedSprite = $AnimatedSprite
onready var _audio_player = $AudioStreamPlayer
onready var _stream_success = preload("res://heart/beat_success.ogg")
onready var _stream_miss = preload("res://heart/beat_fail.ogg")


func _ready() -> void:
# warning-ignore:return_value_discarded
	_animated_sprite.connect("animation_finished", self, "_on_animation_finished")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("beat_input"):
		_animated_sprite.frame = 0
		_animated_sprite.play()


func _on_animation_finished() -> void:
	_animated_sprite.stop()


func _on_SongManager_beat_hit(input_delay: float, _index: int, _action: String) -> void:
	if abs(input_delay) < Globals.MISS_THRESHOLD:
		_audio_player.stream = _stream_success
	else:
		_audio_player.stream = _stream_miss
		_audio_player.play()
		
