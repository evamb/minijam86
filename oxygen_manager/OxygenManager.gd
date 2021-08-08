extends Node2D

signal oxygen_updated
signal limb_died
signal died
signal beat_clock

var _limb_oxygen_count = {
	"arm_left": 2,
	"arm_right": 2,
	"leg_right": 2,
	"leg_left": 2,
}
var _limb_index = 0
var _has_started = false
var _dead_limbs = []
var _dance_prepared = false
var _clock_count = 0

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
onready var _dead_limb_sprites = {
	"arm_left": $ArmLeft/Broken,
	"arm_right": $ArmRight/Broken,
	"leg_right": $LegRight/Broken,
	"leg_left": $LegLeft/Broken,
}
onready var _tween = $Tween
onready var _dance_move_label = $DanceMoveLabel
onready var Oxygen = preload("res://oxygen_manager/Oxygen.tscn")


func _ready() -> void:
	randomize()
	_prepare_dance()
	# this is needed for the first note
	_clock_count += 1
	_update_labels(_limb_oxygen_count)
# warning-ignore:return_value_discarded
	connect("oxygen_updated", self, "_update_labels")


func _on_SongManager_beat_hit(input_delay: float, _beat_index: int, action: String) -> void:
	if abs(input_delay) > Globals.MISS_THRESHOLD:
		return
	if abs(input_delay) > Globals.PERFECT_THRESHOLD:
		_spawn_oxygen(action)
	else:
		_spawn_oxygen(action)
		yield(get_tree().create_timer(0.25), "timeout")
		_spawn_oxygen(action)


func _spawn_oxygen(input_action) -> void:
	var possible_actions = _dead_limbs.duplicate()
	possible_actions.append(input_action)
	var action = possible_actions[randi() % possible_actions.size()]
	
	var oxygen = Oxygen.instance()
	add_child(oxygen)
	_tween.interpolate_property(oxygen, "position", Vector2.ZERO, _limb_locations[action].position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	_tween.interpolate_property(oxygen, "modulate", Color.white, Color.transparent, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_tween.start()
	yield(get_tree().create_timer(0.5), "timeout")
	oxygen.queue_free()
	_limb_oxygen_count[action] -= 1
	emit_signal("oxygen_updated", _limb_oxygen_count)


func _update_labels(limb_oxygen_count) -> void:
	var keys = _limb_labels.keys()
	var dying_limbs = []
	for limb in keys:
		if limb_oxygen_count[limb] <= 0:
			_limb_labels[limb].text = "OK!"
		else:
			_limb_labels[limb].text = str(limb_oxygen_count[limb])
			


func _on_SongManager_started(_bpm: float) -> void:
	_has_started = true


func _prepare_dance() -> void:
	var requirements = Globals.DANCE_MOVES[randi() % Globals.DANCE_MOVES.size()]
	_limb_oxygen_count = requirements.duplicate()
	var rest_oxygen = 0
	for dead in _dead_limbs:
		rest_oxygen += _limb_oxygen_count[dead]
	var living_limbs = _limb_labels.keys()
	while rest_oxygen > 0:
		rest_oxygen -= 1
		_limb_oxygen_count[living_limbs[randi() % living_limbs.size()]] += 1
	
	emit_signal("oxygen_updated", _limb_oxygen_count)
	_clock_count = 7


func _check_limbs() -> void:
	var limbs = _limb_labels.keys()
	for limb in limbs:
		if _limb_oxygen_count[limb] > 0:
			_dead_limbs.append(limb)
			emit_signal("limb_died", limb)
			_tween.interpolate_property(_dead_limb_sprites[limb], "modulate", Color.transparent, Color.white, 1)
			_tween.start()
			_limb_labels[limb].text = "X"
			_limb_labels.erase(limb)
	if _dead_limbs.size() == 4:
		emit_signal("died")
	else:
		_prepare_dance()


func _on_SongManager_beat_clock() -> void:
	_clock_count -= 1
	emit_signal("beat_clock")
	if _clock_count < 0:
		_check_limbs()
	if not _has_started or _limb_labels.size() == 0:
		return
	_dance_move_label.text = str(_clock_count)
