extends Node

signal started


func _ready() -> void:
	get_tree().paused = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("beat_input"):
		get_tree().paused = false
		set_process(false)
		emit_signal("started")
		
