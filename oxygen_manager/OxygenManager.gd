extends Node2D

signal oxygen_updated

var _limb_oxygen_count = {
	"arm_left": 0,
	"arm_right": 0,
	"leg_right": 0,
	"leg_left": 0,
}
var _limb_index = 0
var _has_started = false

onready var _limb_locations = {
	"arm_left": $ArmLeft,
	"arm_right": $ArmRight,
	"leg_right": $LegRight,
	"leg_left": $LegLeft,
}
onready var _limb_labels = {
	"arm_left": $ArmLeftLabel,
	"arm_right": $ArmRightLabel,
	"leg_right": $LegRightLabel,
	"leg_left": $LegLeftLabel,
}
onready var _tween = $Tween
onready var Oxygen = preload("res://oxygen_manager/Oxygen.tscn")


func _ready() -> void:
	pass


func _on_SongManager_beat_hit(input_delay: float, _beat_index: int, action: String) -> void:
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
	_tween.interpolate_property(oxygen, "modulate", Color.white, Color.transparent, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_tween.start()
	yield(get_tree().create_timer(0.5), "timeout")
	oxygen.queue_free()
	_limb_oxygen_count[action] += 1
	emit_signal("oxygen_updated", _limb_oxygen_count)
	_update_labels()


func _update_labels() -> void:
	var keys = _limb_labels.keys()
	for limb in keys:
		_limb_labels[limb].text = str(_limb_oxygen_count[limb])


func _on_SongManager_started(_bpm: float) -> void:
	_has_started = true


func _on_SongManager_beat_clock() -> void:
	if not _has_started:
		return
	_limb_index += 1
	var limbs = _limb_labels.keys()
	_limb_oxygen_count[limbs[_limb_index % limbs.size()]] -= 1
	_update_labels()
