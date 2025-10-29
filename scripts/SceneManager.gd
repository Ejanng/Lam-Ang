extends Node

var target_spawn_point: String = ""

func change_scene_to(scene_path: String, spawn_point: String):
	target_spawn_point = spawn_point
	print("SceneTransition: Changing to ", scene_path, " with spawn point: ", spawn_point)
	get_tree().change_scene_to_file(scene_path)
