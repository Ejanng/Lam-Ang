extends CharacterBody2D

const SPEED = 150
var player_chase = false
var player = null
var health = 100 
var isPlayerInAttackRange = false
var canTakeDMG = true
var meleeDMG = 20
@onready var anim = $AnimatedSprite2D
@onready var takeDMGCD = $take_dmg_cooldown


func _physics_process(delta: float) -> void:
	handle_movement()
	deal_dmg()
		
	
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
	player = body
	player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		isPlayerInAttackRange = true

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		isPlayerInAttackRange = true

func deal_dmg():
	if isPlayerInAttackRange and Global.playerCurrentAttack == true:
		if canTakeDMG:
			health -= meleeDMG
			takeDMGCD.start()
			canTakeDMG = false
			print("Player Deals DMG: ", meleeDMG, "\nEnemy Health: ", health)
		if health <= 0:
			self.queue_free()

func _on_take_dmg_cooldown_timeout() -> void:
	canTakeDMG = true
