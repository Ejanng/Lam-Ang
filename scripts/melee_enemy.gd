extends CharacterBody2D

const SPEED = 40
const WANDER_SPEED = 20
const WANDER_INTERVAL = 2.5
const ATTACK_PAUSE_TIME = 1.0
const ATTACK_RANGE = 15.0
const WANDER_CHANCE = 0.6

var isPlayerInAttackRange = false
var canTakeDMG = true
var isAttacking= false
var canAttack = true

var player = null
var health = 100 
var enemyDMG = 20

@export var xpDrop = 20
@export var xpDropChance = 0.8
@export var coinDrop = 25
@export var coinDropChance = 0.6
@export var healthPotionDrop = 1
@export var healthPotionDropChance = 1
@export var energyPotionDrop = 1
@export var energyPotionDropChance = 1
@export var lootDrop: InventoryItem
@export var lootDropChance: float = 0.4

var random_dir: Vector2 = Vector2.ZERO

@onready var anim = $AnimatedSprite2D
@onready var takeDMGCD = $take_dmg_cooldown
@onready var health_bar = $HealthBar
@onready var wanderTimer = $WanderTimer
@onready var attackPauseTimer = $AttackPauseTimer
@onready var attackCooldown = $AttackCooldown

func _ready() -> void:
	health_bar.max_value = health
	health_bar.value = health
	wanderTimer.wait_time = WANDER_INTERVAL
	wanderTimer.one_shot = false
	wanderTimer.start()

func _physics_process(delta: float) -> void:
	handle_movement()
	
	if isPlayerInAttackRange and not isAttacking and canAttack:
		perform_attack()
		
func handle_movement():
	if Global.player_chase and player:
		var distance = position.distance_to(player.position)
		var direction = (player.position - position).normalized()
		
		if distance > ATTACK_RANGE and not isAttacking:
			velocity = velocity.lerp(direction * SPEED, 0.15)
			move_and_slide()
			anim.play("walk_side")
			anim.flip_h = direction.x < 0
		else:
			velocity = Vector2.ZERO
			if not isAttacking:
				anim.play("idle")
	else:
		if random_dir.length() > 0:
			velocity = random_dir * WANDER_SPEED
			move_and_slide()
			anim.play("walk_side")
			anim.flip_h = random_dir.x < 0
		else:
			velocity = Vector2.ZERO
			anim.play("idle")
			
func _on_wander_timer_timeout() -> void:
	if randf() <= WANDER_CHANCE:
		random_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		#print("Enemy wandering on random direction: ", random_dir)
	else:
		random_dir = Vector2.ZERO
		#print("Enemy idling")

func perform_attack():
	if isAttacking or not canAttack:
		return
	canAttack = false
	isAttacking = true
	velocity = Vector2.ZERO
	#anim.play("attack")   # save for attack animation
	#print("Enemy attacks player!")
	
	var hitChance= 0.8
	var roll = randf()
	
	if player and is_instance_valid(player) and isPlayerInAttackRange:
		if roll <= hitChance:
			if player.has_method("take_damage"):
				player.take_damage(enemyDMG - Global.defBuff)
				#print("Enemy dealt ", enemyDMG - Global.addDef, " damage to player!")
		else:
			print("Enemy missed the attack")
	attackPauseTimer.start()
	attackCooldown.start()
	
func enemy():
	pass

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player = body
		Global.player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player = null
		Global.player_chase = false
	
func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		isPlayerInAttackRange = true
		perform_attack()

func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		isPlayerInAttackRange = false

func deal_dmg(damage):
	if not canTakeDMG:
		return
	canTakeDMG = false
	health -= damage
	health_bar.value = health
	#print("Player Deals DMG: ", damage, "\nEnemy Health: ", health)
	
	takeDMGCD.stop()
	takeDMGCD.start()
		
	if health <= 0:
		die()
			
func die():
	DropManager.drop_xp(global_position, xpDrop, xpDropChance)
	DropManager.drop_coin(global_position, coinDrop, coinDropChance)
	
	var roll = randi_range(1, 2)
	print(roll)
	match roll:
		1:
			DropManager.drop_items("healthPot", global_position, healthPotionDropChance)
		2:
			DropManager.drop_items("energyPot", global_position, energyPotionDropChance)
		#3:
			#DropManager.drop_item(global_position, Drop, coinDropChance)
		#4:
			#DropManager.drop_item(global_position, coinDrop, coinDropChance)
		#5:
			#DropManager.drop_item(global_position, coinDrop, coinDropChance)
	queue_free()

func _on_take_dmg_cooldown_timeout() -> void:
	canTakeDMG = true
	#print("Cooldwon finished - enemy can take damage again")


func _on_attack_pause_timer_timeout() -> void:
	isAttacking = false
	#print("Enemy movement resumed after attack pause.")


func _on_attack_cooldown_timeout() -> void:
	canAttack = true
