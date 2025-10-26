# SceneManager.gd

extends Node

var spawn_position: Vector2 = Vector2.ZERO

const SPAWN_POINTS = {
	# SCENE 1 (Spawn points in Scene1)
	"res://scenes/Tutorial/Scene1.tscn": {
		"From_2_1": Vector2(613, 618) # Player appears at (800, 300) when returning from Scene2_1
	},
	
	# SCENE 2_1 (Spawn points in Scene2_1)
	"res://scenes/Tutorial/Scene2_1.tscn": {
		"From_1": Vector2(616, 68),   # Player appears at (100, 300) when entering from Scene1
		"From_2_2": Vector2(1094, 383)  # Player appears at (500, 950) when returning from Scene2_2
	},
	
	# SCENE 2_2 (Spawn points in Scene2_2)
	"res://scenes/Tutorial/Scene2_2.tscn": {
		"From_2_1": Vector2(500, 50)   # Player appears at (500, 50) when entering from Scene2_1
	},
	
	# SCENE 3 and SCENE 4 are dead ends, they don't need spawn points defined here.
	# The game will reload the player scene, and the death logic will take over.
}

func change_scene_and_set_spawn(target_scene_path: String, path_key: String):
	# This logic finds the correct place to spawn the player in the new scene.
	if SPAWN_POINTS.has(target_scene_path) and SPAWN_POINTS[target_scene_path].has(path_key):
		spawn_position = SPAWN_POINTS[target_scene_path][path_key]
	else:
		# If no specific spawn is found (like for Scene3/4, or if player starts a fresh game)
		spawn_position = Vector2.ZERO
	
	get_tree().change_scene_to_file(target_scene_path)
