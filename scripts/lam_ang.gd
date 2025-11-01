extends CharacterBody2D

const WALK = 100
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
var attackIP = false
var isRegeningHP = false
var isPassiveCD = false
var isRegeningEnergy = false
var isDashing = false
var isSprinting = false
var isAttacking = false
var isHurt = false

# Unified movement + dialogue flags
var can_move: bool = true
var dialogue_active: bool = false
var dialogue_lock: bool = false
var dialogue_manager

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
	# Initialize UI + stats
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

	# connect DialogueManager signals (safe guard: try both singleton and autoload)
	var dm = null
	if Engine.has_singleton("DialogueManager"):
		dm = Engine.get_singleton("DialogueManager")
	else:
		dm = get_node_or_null("/root/DialogueManager")

	if dm:
		# connect only if not already connected
		if not dm.is_connected("dialogue_started", Callable(self, "_on_dialogue_started")):
			dm.connect("dialogue_started", Callable(self, "_on_dialogue_started"))
		if not dm.is_connected("dialogue_ended", Callable(self, "_on_dialogue_ended")):
			dm.connect("dialogue_ended", Callable(self, "_on_dialogue_ended"))

	dialogue_manager = dm

func start_dialogue(area: Node) -> void:
	# Safety: if area is null or has no action, ignore
	if not area:
		return

	# Avoid double-starts
	if dialogue_active or dialogue_lock:
		return

	# If dialogue_manager exposes a way to check if it's already playing, use it
	if dialogue_manager:
		# many dialogue systems include a flag or method; check common names:
		if dialogue_manager.has_method("is_playing") and dialogue_manager.is_playing():
			return
		# some plugins have `is_showing` or `is_active`
		if dialogue_manager.has_method("is_showing") and dialogue_manager.is_showing():
			return

	# Lock immediately so multiple key presses can't call action() multiple times
	dialogue_lock = true

	# Call the actionable's action (which should start the dialogue via the DialogueManager)
	# Wrap in a try/catch style safe call
	if area.has_method("action"):
		area.action()
	else:
		# if area exposes a dialogue resource directly, try calling DialogueManager.start
		if dialogue_manager and area.has_meta("dialogue_resource"):
			var res = area.get_meta("dialogue_resource")
			if dialogue_manager.has_method("start"):
				dialogue_manager.start(res)

# ==========================
# ====== DIALOGUE LOGIC =====
# ==========================
func _process(delta: float) -> void:
	cameraMovement()
	health_potion()
	regenPlayerHealth(delta)
	regenPlayerEnergy(delta)

	# If dialogue is active, we don't start another; but we DO allow advancing through DialogueManager
	if Input.is_action_just_pressed("ui_accept"):
		# If dialogue currently running -> advance (do not restart)
		if dialogue_active:
			# Try multiple common method names used by dialogue plugins:
			if dialogue_manager:
				# prefer a known method name if it exists
				if dialogue_manager.has_method("advance_dialogue"):
					dialogue_manager.advance_dialogue()
				elif dialogue_manager.has_method("advance"):
					dialogue_manager.advance()
				elif dialogue_manager.has_method("next"):
					dialogue_manager.next()
				# if none exist, fallback: attempt to emit a signal or do nothing
			return

		# If we already locked starting a dialogue, ignore
		if dialogue_lock:
			return

		# Try to find an actionable and start dialogue via wrapper
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			# use wrapper which sets lock immediately
			start_dialogue(actionables[0])


func _on_dialogue_started() -> void:
	# Dialogue actually started
	dialogue_active = true
	can_move = false
	velocity = Vector2.ZERO
	anim.play("idle")
	# Keep dialogue_lock true until dialogue ends (prevents queued starts)

func _on_dialogue_ended() -> void:
	# Dialogue finished — re-enable movement and release lock after tiny cooldown
	dialogue_active = false
	can_move = true
	# small cooldown to avoid immediate re-trigger from the same key press
	await get_tree().create_timer(0.08).timeout
	dialogue_lock = false



# ==========================
# ====== MOVEMENT & COMBAT =====
# ==========================
func _physics_process(delta: float) -> void:
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
	if not can_move:
		return

	var input = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"),
	)
	velocity = input.normalized() * currentSpeed
	move_and_slide()

	global_position.x = clamp(global_position.x, Global.mapBounds.position.x, Global.mapBounds.position.x + Global.mapBounds.size.x)
	global_position.y = clamp(global_position.y, Global.mapBounds.position.y, Global.mapBounds.position.y + Global.mapBounds.size.y)


# ==========================
# ====== STATS / ENERGY =====
# ==========================
func health_potion():
	if Global.healthPotion > 0:
		print("Before: ", Global.playerHealth)
		Global.playerHealth += (Global.playerHealth * Global.healthPotion)
		print("After: ", Global.playerHealth)
		Global.healthPotion = 0


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


# ==========================
# ====== MOVEMENT =====
# ==========================
func handle_movement(delta):
	if not can_move:
		velocity = Vector2.ZERO
		return

	var direction = Vector2.ZERO
	currentSpeed = 0
	isSprinting = false
	if isHurt:
		return
		#print("Inside canMove block - should not print during dialogue!")
	currentSpeed = WALK
		
	
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


# ==========================
# ====== ATTACK / DAMAGE =====
# ==========================
func attack():
	if not can_move or isHurt:
		return
	isAttacking = false
	if Input.is_action_just_pressed("attack") and not isPassiveCD:
		Global.playerCurrentAttack = true
		attackArea.monitoring = true
		isPassiveCD = true
		attackIP = true
		isAttacking = true
		energyRegenTimer.start()
		passiveTimer.start()

		Global.playerEnergy -= passiveCost
		energyBar.value = Global.playerEnergy

		for body in attackArea.get_overlapping_bodies():
			if Global.playerCurrentAttack and body.has_method("deal_dmg"):
				body.deal_dmg(Global.playerDamage)

		anim.play("attack")
		can_move = false
		dealAttackCD.start()


func die():
	if Global.playerHealth <= 0 and name:
		isPlayerAlive = false
		Global.playerHealth = 0
		queue_free()


func take_damage(damage: int):
	if isPlayerAlive and not isHurt:
		Global.playerHealth -= damage
		Global.playerHealth = clamp(Global.playerHealth, 0, Global.MAX_HEALTH)
		healthBar.value = Global.playerHealth
		isRegeningHP = false
		regenTimer.start()

		if Global.playerHealth > 0:
			isHurt = true
			anim.play("hurt")
			modulate = Color(1, 0.6, 0.6)
			await get_tree().create_timer(0.2).timeout
			modulate = Color(1, 1, 1)
			isHurt = false
		else:
			die()


# ==========================
# ====== SIGNAL HANDLERS =====
# ==========================
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
	pass


func _on_inventory_gui_closed() -> void:
	can_move = true
	get_tree().paused = false


func _on_inventory_gui_opened() -> void:
	can_move = false
	get_tree().paused = true
