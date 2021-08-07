extends Node2D

signal oxygen_updated

var _limb_oxygen_count = {
	"arm_left": 0,
	"arm_right": 0,
	"leg_left": 0,
	"leg_right": 0,
}

onready var _limb_locations = {
	"arm_left": $ArmLeft,
	"arm_right": $ArmRight,
	"leg_left": $LegLeft,
	"leg_right": $LegRight,
}
onready var _tween = $Tween
onready var Oxygen = preload("res://oxygen_manager/Oxygen.tscn")


func _ready() -> void:
	pass


func _on_SongManager_beat_hit(input_delay: float, beat_index: int, action: String) -> void:
	if abs(input_delay) > Globals.MISS_THRESHOLD:
		return
	if abs(input_delay) > Globals.PERFECT_THRESHOLD:
		_spawn_oxygen(action)
	else:
		_spawn_oxygen(action)
		yield(get_tree().create_timer(0.25), "timeout")
		_spawn_oxygen(action)


func _spawn_oxygen(action) -> void:
	var oxygen = Oxygen.instance()
	add_child(oxygen)
	_tween.interpolate_property(oxygen, "position", Vector2.ZERO, _limb_locations[action].position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_tween.start()
	yield(_tween, "tween_completed")
	_limb_oxygen_count[action] += 1
	emit_signal("oxygen_updated", _limb_oxygen_count)
