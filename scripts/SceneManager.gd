# SceneManager.gd

extends Node

var spawn_position: Vector2 = Vector2.ZERO

const SPAWN_POINTS = {
	# Define your scene paths and spawn coordinates here.
	# The Vector2 coordinates are where the player will appear in the DESTINATION scene.
	
	"res://scenes/SceneB.tscn": {
		"From_A": Vector2(50, 750),     
		"From_C": Vector2(950, 750)      
	},
	"res://scenes/SceneA.tscn": {
		"From_B": Vector2(100, 100),    
		"From_E": Vector2(900, 100)      
	},
	"res://scenes/SceneC.tscn": {
		"From_B": Vector2(400, 50),
		"From_D": Vector2(400, 950)
	},
	"res://scenes/SceneD.tscn": {
		"From_C": Vector2(50, 500),
		"From_E": Vector2(950, 500)
	},
	"res://scenes/SceneE.tscn": {
		"From_D": Vector2(500, 50),
		"From_A": Vector2(500, 950)
	}
}

func change_scene_and_set_spawn(target_scene_path: String, path_key: String):
	
	if SPAWN_POINTS.has(target_scene_path) and SPAWN_POINTS[target_scene_path].has(path_key):
		spawn_position = SPAWN_POINTS[target_scene_path][path_key]
	else:
		spawn_position = Vector2.ZERO
	
	get_tree().change_scene_to_file(target_scene_path)
