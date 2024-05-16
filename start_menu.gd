extends MarginContainer

@export var PlayScene : PackedScene

@onready var start_game_button = %StartGameButton
@onready var quit_game_button = %QuitGameButton

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)

func _on_start_game_button_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_packed(PlayScene)
	LevelTransition.fade_from_black()

func _on_quit_game_button_pressed():
	get_tree().quit()

func _on_settings_button_pressed():
	pass # Replace with function body.

func _on_credits_button_pressed():
	pass # Replace with function body.
