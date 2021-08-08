extends Node2D


onready var GameOverScene = preload("res://ui/GameOver.tscn")
onready var canvas_layer = $CanvasLayer


func _ready() -> void:
	pass


func _on_OxygenManager_died(reason: String, clock_count: int) -> void:
	var game_over = GameOverScene.instance()
	canvas_layer.add_child(game_over)
	game_over.show_screen(reason, clock_count)
