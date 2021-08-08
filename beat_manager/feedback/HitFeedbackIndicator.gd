extends AnimatedSprite

enum Status {
	MISS,
	TOO_FAST,
	TOO_SLOW,
	PERFECT
}

onready var _tween = $Tween


func _on_SongManager_beat_hit(input_delay: float, _beat_index: int, _action: String) -> void:
	var frame = Status.PERFECT
	if abs(input_delay) > Globals.MISS_THRESHOLD:
		frame = Status.MISS
	elif abs(input_delay) > Globals.PERFECT_THRESHOLD:
		if input_delay > 0:
			frame = Status.TOO_SLOW
		else:
			frame = Status.TOO_FAST
	
	self.frame = frame
	_tween.interpolate_property(self, "modulate", Color.white, Color.transparent, 1.0)
	_tween.interpolate_property(self, "scale", Vector2(3, 3), Vector2(6, 6), 0.25, Tween.TRANS_BACK, Tween.EASE_OUT)
	_tween.start()
