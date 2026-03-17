extends Area2D

@export var new_scene: String = "res://demo/"

func _on_body_entered(body):
	if body.name == "Player":
		get_tree().call_deferred("change_scene_to_file", new_scene)
