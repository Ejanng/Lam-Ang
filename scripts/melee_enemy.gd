extends CharacterBody2D

const SPEED = 150
var player_chase = false
var player = null
var health = 100 
var isPlayerInAttackRange = false
var canTakeDMG = true
var meleeDMG = 20
var xpDrop = 20
var xpDropChance = 0.8
var coinDrop = 25
var coinDropChance = 0.6
@onready var anim = $AnimatedSprite2D
@onready var takeDMGCD = $take_dmg_cooldown
@onready var health_bar = $HealthBar

func _ready() -> void:
	health_bar.max_value = health
	health_bar.value = health

func _physics_process(delta: float) -> void:
	handle_movement()
		
func handle_movement():
	if player_chase:
		position += (player.position - position)/SPEED
		anim.play("walk_side")
		if (player.position.x - position.x) < 0:
			anim.flip_h = true
		else:
			anim.flip_h = false
	else:
		anim.play("idle")
	
func enemy():
	pass

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player = null
		player_chase = false
	

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		isPlayerInAttackRange = true

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		isPlayerInAttackRange = false

func deal_dmg():
	if not canTakeDMG:
		return
	canTakeDMG = false
	health -= meleeDMG
	health_bar.value = health
	print("Player Deals DMG: ", meleeDMG, "\nEnemy Health: ", health)
	
	takeDMGCD.stop()
	takeDMGCD.start()
		
	if health <= 0:
		die()
			
func die():
	DropManager.drop_xp(global_position, xpDrop, xpDropChance)
	DropManager.drop_coin(global_position, coinDrop, coinDropChance)
	queue_free()

func _on_take_dmg_cooldown_timeout() -> void:
	canTakeDMG = true
	print("Cooldwon finished - enemy can take damage again")
