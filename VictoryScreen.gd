extends CenterContainer

@onready var main_menu_button = %MainMenuButton

func _ready():
	LevelTransition.fade_from_black()
	main_menu_button.grab_focus()

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
