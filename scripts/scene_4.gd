# Scene1.gd

extends Node2D 

func _on_exit_to_2_1_body_entered(body):
	if body.name == "Player":
		SceneManager.change_scene_and_set_spawn("res://Scene2_1.tscn", "From_1")
