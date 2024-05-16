extends StaticBody2D

@onready var animation_player = $AnimationPlayer


func _on_hitbox_area_2d_area_entered(area):
	animation_player.play("Destroyed")
