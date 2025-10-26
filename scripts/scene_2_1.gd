extends Node2D


func _on_exit_to_scene_1_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		SceneManager.change_scene_and_set_spawn("res://scenes/Tutorial/Scene1.tscn", "From_2_1")


func _on_exit_to_scene_2_2_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		SceneManager.change_scene_and_set_spawn("res://scenes/Tutorial/Scene2_2.tscn", "From_2_1")
