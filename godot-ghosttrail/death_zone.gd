extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		get_tree().call_deferred("reload_current_scene")
