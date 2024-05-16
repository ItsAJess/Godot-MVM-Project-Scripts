extends Area2D

func _on_body_entered(body):
	$AnimatedSprite2D.play("collected")
	await get_tree().create_timer(1.2).timeout
	player_data.coin += 1
	queue_free()
