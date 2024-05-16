extends Area2D

func _on_area_2d_body_entered(body):
	$AnimationPlayer.play("Activated")


func _on_body_entered(body):
	if body.name == "Player":
		player_data.life -= 3
