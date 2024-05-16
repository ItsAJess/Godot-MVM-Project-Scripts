extends Node2D



func _ready():
	get_tree().paused = true
	LevelTransition.fade_from_black()
	get_tree().paused = false

func retry():
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_file_path)


func _on_level_completed_retry():
	retry()
