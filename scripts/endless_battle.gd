extends Node2D

var currentWave: int
@export var enemy_melee_scene: PackedScene
@export var enemy_projectile_scene: PackedScene

var startingNodes: int
var currentNodes: int
var waveSpawnEnded


func _ready():
	currentWave = 0
	Global.currentWave = currentWave
	startingNodes = get_child_count()
	currentNodes = get_child_count()
	position_to_next_wave()
	
func position_to_next_wave():
	if currentNodes == startingNodes:
		currentWave += 1
		# add animation if needed
		Global.currentWave = currentWave
		print(currentWave)
	
func _process(delta):
	pass
