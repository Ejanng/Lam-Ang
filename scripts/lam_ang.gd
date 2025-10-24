extends CharacterBody2D

const WALK = 70.0
const SPRINT = 140.0

var isEnemyInAttackRange = false
var enemyAttackCooldown = true
var isPlayerAlive = true
var attackIP = false    # save for attack animation
var isRegeningHP = false
var isPassiveCD = false
var isRegeningEnergy = false

var currentSpeed = 0
var maxEnergy = 70
var playerEnergy = maxEnergy
var maxHealth = 100
var playerHealth = maxHealth
var passiveCost = 5.0
var regenRateHP = 2.0
var regenRateEnergy = 1.0
var playerPos = Vector2.ZERO
var mapBounds = Rect2(0, 0, 1024, 768)
var regenCD = 10.0
var energy = 50

@onready var anim = $AnimatedSprite2D
@onready var attackCD = $attack_cooldown
@onready var healthBar = $HealthBar
@onready var energyBar = $EnergyBar
@onready var dealAttackCD = $deal_attack_cooldown
@onready var regenTimer = $RegenTimer
@onready var passiveTimer = $PassiveCooldown
@onready var energyRegenTimer = $EnergyRegenTimer

func _ready() -> void:
	healthBar.max_value = maxHealth
	healthBar.value = playerHealth
	energyBar.max_value = maxEnergy
	energyBar.value = playerEnergy
	regenTimer.wait_time = regenCD
	regenTimer.one_shot = true
	energyRegenTimer.wait_time = regenCD
	energyRegenTimer.one_shot = true
	
func _process(delta: float) -> void:
	cameraMovement()
	die()
	regenPlayerHealth(delta)
	regenPlayerEnergy(delta)
	
func _physics_process(delta: float) -> void:
	handle_movement()
	enemy_attack()
	attack()
	
func cameraMovement():
	var input = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"),
	)
	velocity = input.normalized() * currentSpeed
	move_and_slide()
	
	global_position.x = clamp(global_position.x, mapBounds.position.x, mapBounds.position.x + mapBounds.size.x)
	global_position.y = clamp(global_position.y, mapBounds.position.x, mapBounds.position.y + mapBounds.size.y)
	
func regenPlayerHealth(delta) -> void:
	if isRegeningHP and playerHealth < maxHealth:
		playerHealth += regenRateHP * delta
		playerHealth = clamp(playerHealth, 0, maxHealth)
		healthBar.value = playerHealth

func regenPlayerEnergy(delta) -> void:
	if isRegeningEnergy and playerEnergy < maxEnergy:
		playerEnergy += regenRateEnergy * delta
		playerEnergy = clamp(playerEnergy, 0, maxEnergy)
		energyBar.value = playerEnergy

func handle_movement():
	var direction = Vector2.ZERO
	currentSpeed = WALK
	if Input.is_action_pressed("ui_select"):
		currentSpeed = SPRINT
	
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
		velocity = direction * currentSpeed
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
	#if body.has_method("melee_enemy") || body.has_method("ranged_enemy"):
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
		isRegeningHP = false
		attackCD.start()
		regenTimer.start()
		print("Player Health: ", playerHealth)

func _on_attack_cooldown_timeout() -> void:
	enemyAttackCooldown = true

func attack():
	var dir = playerPos
	if Input.is_action_just_pressed("attack") and not isPassiveCD:
		Global.playerCurrentAttack = true
		attackIP = true
		isPassiveCD = true
		energyRegenTimer.start()
		passiveTimer.start()
		playerEnergy -= passiveCost
		print(passiveCost)
		energyBar.value = playerEnergy
			
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

func _on_regen_timer_timeout() -> void:
	isRegeningHP = true

func _on_passive_cooldown_timeout() -> void:
	isPassiveCD = false

func _on_energy_regen_timer_timeout() -> void:
	isRegeningEnergy = true
