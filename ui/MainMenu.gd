extends ColorRect

onready var q = $VBoxContainer/HBoxContainer/Q
onready var e = $VBoxContainer/HBoxContainer/E
onready var a = $VBoxContainer/HBoxContainer/A
onready var d = $VBoxContainer/HBoxContainer/D
onready var _audio_player = $AudioStreamPlayer


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
	_start_game()


func _start_game() -> void:
	yield(_audio_player, "finished")
	get_tree().change_scene("res://Main.tscn")
