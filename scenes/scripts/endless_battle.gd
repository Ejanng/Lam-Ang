extends Node2D
#
#@onready var transitionAnimtation = $Node2D

var currentWave: int
@export var enemy_melee_scene: PackedScene
@export var enemy_projectile_scene: PackedScene

var startingNodes: int
var currentNodes: int
var waveSpawnEnded


func _ready():
	currentWave = 10
	Global.currentWave = currentWave
	startingNodes = get_child_count()
	currentNodes = get_child_count()
	position_to_next_wave()
	
func position_to_next_wave():
	if currentNodes == startingNodes:
		if currentWave != 0:
			Global.moveingToNextWave = true
		waveSpawnEnded = false
		#transitionAnimtation.play("wave_start")
		currentWave += 1
		Global.currentWave = currentWave
		#await get_tree().create_timer(0.5).timeout
		prepare_spawn("melee", 6.0, 6.0)       # type, multiplier, mob_spawns
		prepare_spawn("projectile", 6.0, 6.0)
		print(currentWave)
	
func prepare_spawn(type, multiplier, mobSpawns):
	var mobAmount = float(currentWave) * multiplier
	var mobWaitTime = 2.0
	print("mob amount: ", mobAmount)
	var mobSpawnRounds = mobAmount / mobSpawns
	spawn_type(type, mobSpawnRounds, mobWaitTime)
	
func spawn_type(type, mobSpawnRounds, mobWaitTime):
	if type == "melee":
		var meleeSpawn1 = $MeleeTribeSpawnPoint1
		var meleeSpawn2 = $MeleeTribeSpawnPoint2
		var meleeSpawn3 = $MeleeTribeSpawnPoint3
		var meleeSpawn4 = $MeleeTribeSpawnPoint4
		var meleeSpawn5 = $MeleeTribeSpawnPoint5
		var meleeSpawn6 = $MeleeTribeSpawnPoint6
		if mobSpawnRounds >= 1:
			for i in mobSpawnRounds:
				var melee1 = enemy_melee_scene.instantiate()
				melee1.global_position = meleeSpawn1.global_position
				var melee2 = enemy_melee_scene.instantiate()
				melee2.global_position = meleeSpawn2.global_position
				var melee3 = enemy_melee_scene.instantiate()
				melee3.global_position = meleeSpawn3.global_position
				var melee4 = enemy_melee_scene.instantiate()
				melee4.global_position = meleeSpawn4.global_position
				var melee5 = enemy_melee_scene.instantiate()
				melee5.global_position = meleeSpawn5.global_position
				var melee6 = enemy_melee_scene.instantiate()
				melee6.global_position = meleeSpawn6.global_position
				add_child(melee1)
				add_child(melee2)
				add_child(melee3)
				add_child(melee4)
				add_child(melee5)
				add_child(melee6)
				mobSpawnRounds -= 1
				await get_tree().create_timer(mobWaitTime).timeout
	# uncomment if scene is loaded (projectile)
	#elif type == "projectile":
		#var projectileSpawn1 = $ProjectileTribeSpawnPoint1
		#var projectileSpawn2 = $ProjectileTribeSpawnPoint2
		#var projectileSpawn3 = $ProjectileTribeSpawnPoint3
		#var projectileSpawn4 = $ProjectileTribeSpawnPoint4
		#var projectileSpawn5 = $ProjectileTribeSpawnPoint5
		#var projectileSpawn6 = $ProjectileTribeSpawnPoint6
		#if mobSpawnRounds >= 1:
			#for i in mobSpawnRounds:
				#var projectile1 = enemy_projectile_scene.instantiate()
				#projectile1.global_position = projectileSpawn1.global_position
				#var projectile2 = enemy_melee_scene.instantiate()
				#projectile2.global_position = projectileSpawn2.global_position
				#var projectile3 = enemy_melee_scene.instantiate()
				#projectile3.global_position = projectileSpawn3.global_position
				#var projectile4 = enemy_melee_scene.instantiate()
				#projectile4.global_position = projectileSpawn4.global_position
				#var projectile5 = enemy_melee_scene.instantiate()
				#projectile5.global_position = projectileSpawn5.global_position
				#var projectile6 = enemy_melee_scene.instantiate()
				#projectile6.global_position = projectileSpawn6.global_position
				#add_child(projectile1)
				#add_child(projectile2)
				#add_child(projectile3)
				#add_child(projectile4)
				#add_child(projectile5)
				#add_child(projectile6)
				#mobSpawnRounds -= 1
				#await get_tree().create_timer(mobWaitTime).timeout
		waveSpawnEnded = true
	#
func _process(delta):
	currentNodes = get_child_count()
	if waveSpawnEnded:
		position_to_next_wave()
