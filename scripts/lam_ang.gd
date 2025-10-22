extends CharacterBody2D

const WALK = 70.0
const SPRINT = 140.0

var isEnemyInAttackRange = false
var enemyAttackCooldown = true
var playerHealth = 100
var isPlayerAlive = true

@onready var anim = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	handle_movement()

func attack():
	pass
	
func hurt():
	pass
	
func die():
	pass

func handle_movement():
	var direction = Vector2.ZERO
	
	var current_speed = WALK
	if Input.is_action_pressed("ui_select"):
		current_speed = SPRINT
	
	# movements directions
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	
	# animated sprites
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * current_speed
		move_and_slide()
		
		if abs(direction.x) > abs(direction.y):
			anim.play("walk_side")
			anim.flip_h = direction.x < 0 
		else:
			if direction.y < 0:
				anim.play("walk_up")
			else:
				anim.play("walk_down")
	else:
		velocity = Vector2.ZERO
		anim.play("idle")


func player():
	pass

func _on_punch_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		isEnemyInAttackRange = true
		

func _on_punch_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		isEnemyInAttackRange = false
		
func enemy_attack():
	print("player took dmg")
