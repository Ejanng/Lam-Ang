extends CharacterBody2D

const WALK = 0.1
const SPRINT = 15
const DASH_SPEED = 600

const REGEN_RATE_ENERGY = 10.0
const REGEN_RATE_HP = 2.0
const ENERGY_DECAY_RATE_SPRINT = 2.0

const REGEN_CD = 5
const DOUBLE_TAP_WINDOW = 0.3
const DASH_ENERGY_COST = 5.0

var doubleTapTimers = {
	"left": 0.0,
	"right": 0.0,
	"up": 0.0,
	"down": 0.0,
}

var isEnemyInAttackRange = false
var isPlayerAlive = true
var attackIP = false    # save for attack animation
var isRegeningHP = false
var isPassiveCD = false
var isRegeningEnergy = false
var isDashing = false
var isSprinting = false
var isAttacking = false
var isHurt = false

# Unified movement flag (use this everywhere)
var can_move: bool = true
var dialogue_active: bool = false

var currentSpeed = 0
var dashDirection = Vector2.ZERO
var passiveCost = 5.0

var playerPos = Vector2.ZERO

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
@onready var coinLabel = $CoinLabel
@onready var actionable_finder: Area2D = $Direction/ActionableFinder
@onready var inventoryGui = $InventoryGui


func _ready() -> void:
	healthBar.max_value = Global.MAX_HEALTH
	healthBar.value = Global.playerHealth
	energyBar.max_value = Global.MAX_ENERGY
	energyBar.value = Global.playerEnergy
	regenTimer.wait_time = REGEN_CD
	regenTimer.one_shot = true
	energyRegenTimer.wait_time = REGEN_CD
	energyRegenTimer.one_shot = true
	xpBar.value = Global.playerXP
	xpBar.max_value = Global.xpToNextLevel

	inventoryGui.close()
	update_coin_display()
	
# function stats of consumable
func health_potion():
	if Global.healthPotion > 0:
		print("Before: ", Global.playerHealth)
		Global.playerHealth += (Global.playerHealth * Global.healthPotion)
		print("After: ", Global.playerHealth)
		Global.healthPotion = 0

func _process(delta: float) -> void:
	# cameraMovement handles movement clamping; but it will early-return if can_move is false
	cameraMovement()
	health_potion()
	regenPlayerHealth(delta)
	regenPlayerEnergy(delta)
	
	if Input.is_action_just_pressed("ui_accept"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			# start dialogue: set unified movement flag
			dialogue_active = true
			can_move = false  # stop player movement
			actionables[0].action()
			# wait until dialogue is ended (DialogueManager should emit dialogue_ended)
			await DialogueManager.dialogue_ended
			dialogue_active = false
			can_move = true  # re-enable player movement
			return

func _physics_process(delta: float) -> void:
	# central movement block: if movement is locked, stop and return
	if not can_move:
		velocity = Vector2.ZERO
		anim.play("idle")
		return

	handle_movement(delta)
	attack()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		if inventoryGui.isOpen:
			inventoryGui.close()
		else:
			inventoryGui.open()
	
func cameraMovement():
	# Respect single movement flag: do nothing when movement is locked
	if not can_move:
		return

	var input = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"),
	)
	velocity = input.normalized() * currentSpeed
	move_and_slide()
	
	global_position.x = clamp(global_position.x, Global.mapBounds.position.x, Global.mapBounds.position.x + Global.mapBounds.size.x)
	global_position.y = clamp(global_position.y, Global.mapBounds.position.x, Global.mapBounds.position.y + Global.mapBounds.size.y)
	
func regenPlayerHealth(delta) -> void:
	if isRegeningHP and Global.playerHealth < Global.MAX_HEALTH:
		Global.playerHealth += REGEN_RATE_HP * delta
		Global.playerHealth = clamp(Global.playerHealth, 0, Global.MAX_HEALTH)
		healthBar.value = Global.playerHealth

func regenPlayerEnergy(delta) -> void:
	if isRegeningEnergy and Global.playerEnergy < Global.MAX_ENERGY:
		Global.playerEnergy += REGEN_RATE_ENERGY * delta
		Global.playerEnergy = clamp(Global.playerEnergy, 0, Global.MAX_ENERGY)
		energyBar.value = Global.playerEnergy
	if isDashing or isSprinting or isAttacking:
		isRegeningEnergy = false
		
func add_experience(amount: int) -> void:
	Global.playerXP += amount
	xpBar.value = Global.playerXP
	
	if Global.playerXP >= Global.xpToNextLevel:
		Global.playerXP -= Global.xpToNextLevel
		Global.playerXP += 1
		Global.playerLevel += 1
		Global.xpToNextLevel = int(Global.xpToNextLevel * 1.2)
		xpBar.value = Global.playerXP
		
func add_coin(amount: int) -> void:
	Global.playerCoin += amount
	update_coin_display()
	
func update_coin_display() -> void:
	coinLabel.text = "Coins: " + str(Global.playerCoin)
	
func handle_movement(delta):
	# unified movement check
	if not can_move:
		velocity = Vector2.ZERO
		return
		
	var direction = Vector2.ZERO
	currentSpeed = 0
	isSprinting = false
	if isHurt:
		return
	currentSpeed = WALK + Global.addSpeed		
	
	if isDashing:
		velocity = dashDirection * DASH_SPEED
		move_and_slide()
		return
	else:
		for dir in doubleTapTimers.keys():
			if doubleTapTimers[dir] > 0:
				doubleTapTimers[dir] -= delta
				
		if Input.is_action_pressed("ui_select"):
			if Global.playerEnergy >= ENERGY_DECAY_RATE_SPRINT:
				isRegeningEnergy = false
				isSprinting = true
				Global.playerEnergy -= ENERGY_DECAY_RATE_SPRINT * delta
				Global.playerEnergy = clamp(Global.playerEnergy, 0, Global.MAX_ENERGY)
				energyBar.value = Global.playerEnergy
				energyRegenTimer.start()
				currentSpeed = SPRINT
			
		# movement directions
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
		handle_double_dash()

func handle_double_dash():
	# prevent dashing when movement locked
	if not can_move:
		return

	for dir in ["left", "right", "up", "down"]:
		if Input.is_action_just_pressed("ui_" + dir):
			if doubleTapTimers[dir] > 0:
				if Global.playerEnergy >= DASH_ENERGY_COST:
					start_dash(dir)
					Global.playerEnergy -= DASH_ENERGY_COST
					energyBar.value = Global.playerEnergy
					energyRegenTimer.start()
				else:
					print("Not enough energy to dash!")
				doubleTapTimers[dir] = 0.0
			else:
				doubleTapTimers[dir] = DOUBLE_TAP_WINDOW

func start_dash(dir):
	isDashing = true
	dashTimer.start()
	
	match dir:
		"left":
			dashDirection = Vector2.LEFT
		"right":
			dashDirection = Vector2.RIGHT
		"up":
			dashDirection = Vector2.UP
		"down":
			dashDirection = Vector2.DOWN
			
func attack():
	# prevent attacking when movement locked or when hurt
	if not can_move or isHurt:
		return
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
		
		Global.playerEnergy -= passiveCost
		energyBar.value = Global.playerEnergy
		
		for body in attackArea.get_overlapping_bodies():
			if Global.playerCurrentAttack and body.has_method("deal_dmg"):
				body.deal_dmg(Global.playerDamage)
			
		# handle the attack animations
		anim.play("attack")
		can_move = false
		dealAttackCD.start()

func die():
	if Global.playerHealth <= 0 and name:
		isPlayerAlive = false
		Global.playerHealth = 0
		self.queue_free()
		
func player():
	pass

func take_damage(damage: int):
	if isPlayerAlive and not isHurt:
		Global.playerHealth -= damage
		Global.playerHealth = clamp(Global.playerHealth, 0, Global.MAX_HEALTH)
		healthBar.value = Global.playerHealth
		isRegeningHP = false
		regenTimer.start()  # Reset health regen timer
		
		if Global.playerHealth > 0:
			isHurt = true
			anim.play("hurt")
			modulate = Color(1, 0.6, 0.6)
			await get_tree().create_timer(0.2).timeout
			modulate = Color(1, 1, 1)
			isHurt = false
		else:
			die()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		isEnemyInAttackRange = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		isEnemyInAttackRange = false

func _on_deal_attack_cooldown_timeout() -> void:
	Global.playerCurrentAttack = false
	attackArea.monitoring = false
	attackIP = false
	# re-enable movement after attack cooldown
	can_move = true

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
		body.deal_dmg(Global.playerDamage)

func _on_exit_to_scene_2_2_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

func _on_inventory_gui_closed() -> void:
	can_move = true
	get_tree().paused = false

func _on_inventory_gui_opened() -> void:
	can_move = false
	get_tree().paused = true
