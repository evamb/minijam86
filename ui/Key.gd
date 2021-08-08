extends Panel


export(String) var action

onready var _tween = $Tween
onready var _label = $Label


func _process(delta: float) -> void:
	if Input.is_action_just_pressed(action):
		_tween.interpolate_property(self, "modulate", Color.yellow, Color.white, 0.5)
		_tween.start()
