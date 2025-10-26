# Scene2_2.gd

extends Node2D 


func _on_exit_to_scene_2_1_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		SceneManager.change_scene_and_set_spawn("res://scenes/Tutorial/Scene2_1.tscn", "From_2_2")
	

func _on_exit_to_scene_2_2_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		SceneManager.change_scene_and_set_spawn("res://scenes/Tutorial/Scene3.tscn", "From_2_2")
