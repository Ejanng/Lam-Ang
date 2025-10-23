extends CharacterBody2D

const WALK = 70.0
const SPRINT = 140.0

var isEnemyInAttackRange = false
var enemyAttackCooldown = true
var playerHealth = 100
var maxHealth = 100
var isPlayerAlive = true
var attackIP = false    # save for attack animation
var playerPos = Vector2.ZERO

@onready var anim = $AnimatedSprite2D
@onready var attackCD = $attack_cooldown
@onready var healthBar = $ProgressBar
@onready var dealAttackCD = $deal_attack_cooldown

func _ready() -> void:
	healthBar.max_value = maxHealth
	healthBar.value = playerHealth

func _physics_process(delta: float) -> void:
	handle_movement()
	enemy_attack()
	die()
	attack()
		
func handle_movement():
	var direction = Vector2.ZERO
	var current_speed = WALK
	if Input.is_action_pressed("ui_select"):
		current_speed = SPRINT
	
	# movements directions
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
		playerPos = direction
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
		playerPos = direction
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
		playerPos = direction
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
		playerPos = direction
	
	# animated sprites
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * current_speed
		move_and_slide()
	
		if abs(direction.x) > abs(direction.y):
			if attackIP == false:
				anim.play("walk_side")
				anim.flip_h = direction.x < 0 
		else:
			if direction.y < 0:
				if attackIP == false:
					anim.play("walk_up")
			else:
				if attackIP == false:
					anim.play("walk_down")
	else:
		velocity = Vector2.ZERO
		anim.play("idle")

func die():
	if playerHealth <= 0 and name:
		isPlayerAlive = false
		playerHealth = 0
		print("Player Died!")
		self.queue_free()
		
func player():
	pass

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		isEnemyInAttackRange = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		isEnemyInAttackRange = false
		
func enemy_attack():
	if isEnemyInAttackRange and enemyAttackCooldown == true:
		playerHealth -= 20
		playerHealth = clamp(playerHealth, 0, maxHealth)
		healthBar.value = playerHealth
		enemyAttackCooldown = false
		attackCD.start()
		print("Player Health: ", playerHealth)

func _on_attack_cooldown_timeout() -> void:
	enemyAttackCooldown = true

func attack():
	var dir = playerPos
	if Input.is_action_just_pressed("attack"):
		Global.playerCurrentAttack = true
		attackIP = true
		if abs(dir.x) > abs(dir.y):
			anim.play("walk_side")
			anim.flip_h = dir.x < 0 
			dealAttackCD.start()
		else:
			if dir.y < 0:
				anim.play("walk_up")
				dealAttackCD.start()
			else:
				anim.play("walk_down")
				dealAttackCD.start()


func _on_deal_attack_cooldown_timeout() -> void:
	dealAttackCD.stop()
	Global.playerCurrentAttack = false
	attackIP = false
