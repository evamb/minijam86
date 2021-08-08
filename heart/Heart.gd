extends Node2D


onready var animated_sprite: AnimatedSprite = $AnimatedSprite


func _ready() -> void:
# warning-ignore:return_value_discarded
	$AnimatedSprite.connect("animation_finished", self, "_on_animation_finished")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("beat_input"):
		$AnimatedSprite.frame = 0
		$AnimatedSprite.play()


func _on_animation_finished() -> void:
	$AnimatedSprite.stop()
