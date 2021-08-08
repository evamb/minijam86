extends ColorRect


onready var _tween = $Tween
onready var _dance_move_count = $CenterContainer/VBoxContainer/DanceMoveCount
onready var _reason = $CenterContainer/VBoxContainer/Reason

func _update_move_count(count: int) -> void:
	_dance_move_count.text = str(count)


func show_screen(reason: String, total_count: int) -> void:
	_reason.text = "Your heart stopped beating" if reason != "oxygen" else "Your limbs ran out of oxygen" 
	_dance_move_count.text = str(total_count)
	_tween.interpolate_property(self, "modulate", Color.transparent, Color.white, .5);
	_tween.interpolate_method(self, "_update_move_count", 0, total_count, 1);	
	_tween.start()


func _on_PlayAgainButton_button_up() -> void:
	get_tree().change_scene("res://Main.tscn")
	
	
func _on_MenuButton_button_up() -> void:
	pass
