tool
extends Node2D


func _get_configuration_warning() -> String:
	if not $SongManager.song is Song:
		return "Song manager must have a valid song"
	return ""
