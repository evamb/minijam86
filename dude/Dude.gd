extends Node2D

var _dead_limbs = []

onready var parts = {
	"arm_left": $ArmLeft,
	"arm_right": $ArmRight,
	"leg_left": $LegLeft,
	"leg_right": $LegRight,
	"body": $Body,
	"head": $Head,
}

func _ready() -> void:
	pass


func _on_OxygenManager_preparation_completed(dance_move_index: int) -> void:
	var elems = parts.keys()
	for elem in elems:
		parts[elem].play("dance_%s_%s" % [
			dance_move_index + 1,
			"dead" if _dead_limbs.has(elem) else "alive"])


func _on_OxygenManager_limb_died(limb: String) -> void:
	_dead_limbs.append(limb)


func _on_OxygenManager_died(_reason: String, _count: int) -> void:
	for elem in parts.values():
		elem.stop()
