extends CharacterBody2D

const WALK = 70.0
const SPRINT = 140.0
const DASH_SPEED = 800

const REGEN_RATE_ENERGY = 10.0
const REGEN_RATE_HP = 2.0
const ENERGY_DECAY_RATE_SPRINT = 5.0

const MAX_ENERGY = 70
const MAX_HEALTH = 100

const REGEN_CD = 5.0
const DOUBLE_TAP_WINDOW = 0.3
const DASH_ENERGY_COST = 20.0

var doubleTapTimers = {
	"left": 0.0,
	"right": 0.0,
	"up": 0.0,
	"down": 0.0,
}

var isEnemyInAttackRange = false
var enemyAttackCooldown = true
var isPlayerAlive = true
var attackIP = false    # save for attack animation
var isRegeningHP = false
var isPassiveCD = false
var isRegeningEnergy = false
var isDashing = false
var isSprinting = false
var isAttacking = false

var playerHealth = MAX_HEALTH
var playerEnergy = MAX_ENERGY
var playerXP = 50
var xpToNextLevel: int = 100
var playerLevel = 1

var currentSpeed = 0
var dashDuration = 0.1
var dashDirection = Vector2.ZERO
var passiveCost = 5.0


var playerPos = Vector2.ZERO
var mapBounds = Rect2(0, 0, 1024, 768)

@onready var anim = $AnimatedSprite2D
@onready var attackCD = $attack_cooldown
@onready var healthBar = $HealthBar
@onready var energyBar = $EnergyBar
@onready var dealAttackCD = $deal_attack_cooldown
@onready var regenTimer = $RegenTimer
@onready var passiveTimer = $PassiveCooldown
@onready var energyRegenTimer = $EnergyRegenTimer
@onready var dashTimer = $DashTimer
@onready var sprintEnergyDecay = $SprintEnergyDecay
@onready var xpBar = $XPBar
@onready var attackArea = $AttackArea

func _ready() -> void:
	healthBar.max_value = MAX_HEALTH
	healthBar.value = playerHealth
	energyBar.max_value = MAX_ENERGY
	energyBar.value = playerEnergy
	regenTimer.wait_time = REGEN_CD
	regenTimer.one_shot = true
	energyRegenTimer.wait_time = REGEN_CD
	energyRegenTimer.one_shot = true
	xpBar.value = playerXP
	xpBar.max_value = xpToNextLevel
	
func _process(delta: float) -> void:
	cameraMovement()
	die()
	regenPlayerHealth(delta)
	regenPlayerEnergy(delta)
	
func _physics_process(delta: float) -> void:
	handle_movement(delta)
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
	if isRegeningHP and playerHealth < MAX_HEALTH:
		playerHealth += REGEN_RATE_HP * delta
		playerHealth = clamp(playerHealth, 0, MAX_HEALTH)
		healthBar.value = playerHealth

func regenPlayerEnergy(delta) -> void:
	if isRegeningEnergy and playerEnergy < MAX_ENERGY:
		playerEnergy += REGEN_RATE_ENERGY * delta
		playerEnergy = clamp(playerEnergy, 0, MAX_ENERGY)
		energyBar.value = playerEnergy
	if isDashing or isSprinting or isAttacking:
		isRegeningEnergy = false
		
func add_experience(amount: int) -> void:
	playerXP += amount
	xpBar.value = playerXP
	print("Gained", amount, "XP. Total: ", playerXP)
	
	if playerXP >= xpToNextLevel:
		playerXP -= xpToNextLevel
		playerXP += 1
		playerLevel += 1
		xpToNextLevel = int(xpToNextLevel * 1.2)
		xpBar.value = playerXP
		print("Level Up! Now Level: ", playerLevel)
		
func handle_movement(delta):
	var direction = Vector2.ZERO
	isSprinting = false
	currentSpeed = WALK
	
	if isDashing:
		velocity = dashDirection * DASH_SPEED
		move_and_slide()
	else:
		for dir in doubleTapTimers.keys():
			if doubleTapTimers[dir] > 0:
				doubleTapTimers[dir] -= delta
				
		if Input.is_action_pressed("ui_select"):
			print(playerEnergy, ENERGY_DECAY_RATE_SPRINT)
			if playerEnergy >= ENERGY_DECAY_RATE_SPRINT:
				isRegeningEnergy = false
				isSprinting = true
				playerEnergy -= ENERGY_DECAY_RATE_SPRINT * delta
				playerEnergy = clamp(playerEnergy, 0, MAX_ENERGY)
				energyBar.value = playerEnergy
				energyRegenTimer.start()
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
				if not attackIP:
					anim.play("walk_side")
					anim.flip_h = direction.x < 0 
			else:
				if not attackIP:
					if direction.y < 0:
						anim.play("walk_up")
					else:
						anim.play("walk_down")
		else:
			if not attackIP:
				anim.play("idle")
		handle_double_dash(direction)
	

func handle_double_dash(direction):
	for dir in ["left", "right", "up", "down"]:
		if Input.is_action_just_pressed("ui_" + dir):
			if doubleTapTimers[dir] > 0:
				if playerEnergy >= DASH_ENERGY_COST:
					start_dash(dir)
					playerEnergy -= DASH_ENERGY_COST
					energyBar.value = playerEnergy
					print("Dashing", dir, "- Energy left: ", playerEnergy)
					energyRegenTimer.start()
				else:
					print("Not enough energy to dash!")
				doubleTapTimers[dir] = 0.0
			else:
				doubleTapTimers[dir] = DOUBLE_TAP_WINDOW

func start_dash(dir):
	isDashing = true
	dashTimer.start(dashDuration)
	
	match dir:
		"left":
			dashDirection = Vector2.LEFT
			print("Im left")
		"right":
			dashDirection = Vector2.RIGHT
			print("Im right")
		"up":
			dashDirection = Vector2.UP
			print("Im up")
		"down":
			dashDirection = Vector2.DOWN
			print("Im down")
			
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
		playerHealth = clamp(playerHealth, 0, MAX_HEALTH)
		healthBar.value = playerHealth
		enemyAttackCooldown = false
		isRegeningHP = false
		attackCD.start()
		regenTimer.start()
		print("Player Health: ", playerHealth)
		
func take_damage(damage: int):
	if isPlayerAlive:
		playerHealth -= damage
		playerHealth = clamp(playerHealth, 0, MAX_HEALTH)
		healthBar.value = playerHealth
		isRegeningHP = false
		regenTimer.start()  # Reset health regen timer
		print("Player took ", damage, " damage. Health: ", playerHealth)

func _on_attack_cooldown_timeout() -> void:
	enemyAttackCooldown = true

func attack():
	var dir = playerPos
	isAttacking = false
	if Input.is_action_just_pressed("attack") and not isPassiveCD:
		# player attack variables
		Global.playerCurrentAttack = true
		attackArea.monitoring = true
		isPassiveCD = true
		# player animtion variables
		attackIP = true
		isAttacking = true
		# timers
		energyRegenTimer.start()
		passiveTimer.start()
		
		
		playerEnergy -= passiveCost
		print(passiveCost)
		energyBar.value = playerEnergy
		
		# issue on player attack at start wont work
		# this function will overide that and deal dmg on enemy will work
		# this function only work once... better not remove it
		for body in attackArea.get_overlapping_bodies():
			if Global.playerCurrentAttack and body.has_method("deal_dmg"):
				body.deal_dmg()
			
		# handle the attack animations
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
				
		# finish the animation first before starting the cd
		dealAttackCD.start()

func _on_deal_attack_cooldown_timeout() -> void:
	Global.playerCurrentAttack = false
	attackArea.monitoring = false
	attackIP = false

func _on_regen_timer_timeout() -> void:
	isRegeningHP = true

func _on_passive_cooldown_timeout() -> void:
	isPassiveCD = false

func _on_energy_regen_timer_timeout() -> void:
	isRegeningEnergy = true

func _on_dash_timer_timeout() -> void:
	isDashing = false

func _on_sprint_energy_decay_timeout() -> void:
	isRegeningEnergy = true


func _on_attack_area_body_entered(body: Node2D) -> void:
	if Global.playerCurrentAttack and body.has_method("deal_dmg"):
		print("do i get calledd?")
		body.deal_dmg()
