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
	
func _process(delta):
	pass
