extends Node2D


func _on_exit_to_scene_2_1_body_entered(body: Node2D) -> void:
	
	if body.name == "Player":
		SceneManager.change_scene_and_set_spawn("res://scenes/SceneB.tscn", "From_A")
