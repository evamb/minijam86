extends ColorRect


onready var _tween = $Tween
onready var _dance_move_count = $CenterContainer/VBoxContainer/DanceMoveCount
onready var _reason = $CenterContainer/VBoxContainer/Reason
onready var _audio_player = $AudioStreamPlayer


func show_screen(reason: String, total_count: int) -> void:
	_reason.text = "Your heart stopped beating" if reason != "oxygen" else "Your limbs ran out of oxygen" 
	yield(get_tree().create_timer(4), "timeout")
	_audio_player.play()
	modulate = Color.white
	_tween.interpolate_method(self, "_update_move_count", 0, total_count, 1);	
	_tween.start()


func _update_move_count(count: int) -> void:
	_dance_move_count.text = str(count)


func _on_PlayAgainButton_button_up() -> void:
	get_tree().change_scene("res://Main.tscn")
	
	
func _on_MenuButton_button_up() -> void:
	pass
