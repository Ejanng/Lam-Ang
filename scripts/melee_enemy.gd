extends CharacterBody2D

const SPEED = 40
const WANDER_SPEED = 20
const WANDER_INTERVAL = 2.5

var player_chase = false
var isPlayerInAttackRange = false
var canTakeDMG = true

var player = null
var health = 100 
var meleeDMG = 20

var xpDrop = 20
var xpDropChance = 0.8
var coinDrop = 25
var coinDropChance = 0.6

var random_dir: Vector2 = Vector2.ZERO

@onready var anim = $AnimatedSprite2D
@onready var takeDMGCD = $take_dmg_cooldown
@onready var health_bar = $HealthBar
@onready var wanderTimer = $WanderTimer

func _ready() -> void:
	health_bar.max_value = health
	health_bar.value = health
	wanderTimer.wait_time = WANDER_INTERVAL
	wanderTimer.one_shot = false
	wanderTimer.start()
	wanderTimer.connect("timeout", _on_wander_timer_timeout)

func _physics_process(delta: float) -> void:
	handle_movement()
		
func handle_movement():
	if player_chase and player:
		var direction = (player.position - position).normalized()
		velocity = direction * SPEED
		move_and_slide()
		
		anim.play("walk_side")
		anim.flip_h = direction.x < 0
	else:
		velocity = random_dir * WANDER_SPEED
		move_and_slide()
		
		if random_dir.length() > 0:
			anim.play("walk_side")
			anim.flip_h = random_dir.x < 0
		else:
			anim.play("idle")
			
func _on_wander_timer_timeout() -> void:
	random_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

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
