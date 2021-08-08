extends ColorRect

onready var q = $HBoxContainer/Q
onready var e = $HBoxContainer/E
onready var a = $HBoxContainer/A
onready var d = $HBoxContainer/D
onready var _audio_player = $AudioStreamPlayer
onready var _tween = $Tween

var _pressed = {
	"q": false,
	"e": false,
	"a": false,
	"d": false,
}


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("arm_left"):
		_pressed.q = true
		q.modulate = Color.green
		_audio_player.play()
	if Input.is_action_just_pressed("arm_right"):
		_pressed.e = true
		e.modulate = Color.green
		_audio_player.play()
	if Input.is_action_just_pressed("leg_left"):
		_pressed.a = true
		a.modulate = Color.green
		_audio_player.play()
	if Input.is_action_just_pressed("leg_right"):
		_pressed.d = true
		d.modulate = Color.green
		_audio_player.play()
	for val in _pressed.values():
		if not val:
			return
	set_process(false)
	_start_game()


func _start_game() -> void:
	_tween.interpolate_property(self, "modulate", Color.white, Color.black, 1)
	_tween.start()
	yield(_tween, "tween_completed")
	get_tree().change_scene("res://Main.tscn")
