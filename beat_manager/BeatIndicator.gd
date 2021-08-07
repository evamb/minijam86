extends Sprite


var _speed = 0.0


func set_speed(speed: float) -> void:
	_speed = speed


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	position.x -= delta * _speed
