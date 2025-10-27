# SceneManager.gd

extends Node

var spawn_position: Vector2 = Vector2.ZERO

const SPAWN_POINTS = {
	# SCENE 1 (Spawn points in Scene1)
	"res://scenes/Tutorial/Scene1.tscn": {
		"From_2_1": Vector2(613, 618) 
	},
	
	# SCENE 2_1 (Spawn points in Scene2_1)
	"res://scenes/Tutorial/Scene2_1.tscn": {
		"From_1": Vector2(616, 68),  
		"From_2_2": Vector2(1094, 383)  
	},
	
	# SCENE 2_2 (Spawn points in Scene2_2)
	"res://scenes/Tutorial/Scene2_2.tscn": {
		"From_2_1": Vector2(500, 50) 
	},
}

func change_scene_and_set_spawn(target_scene_path: String, path_key: String):
	# This logic finds the correct place to spawn the player in the new scene.
	if SPAWN_POINTS.has(target_scene_path) and SPAWN_POINTS[target_scene_path].has(path_key):
		spawn_position = SPAWN_POINTS[target_scene_path][path_key]
	else:
		spawn_position = Vector2(43, 293)
	
	get_tree().change_scene_to_file(target_scene_path)
