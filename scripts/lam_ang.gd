extends CharacterBody2D

const SPEED = 200.0
@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO
	
	# movements
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
		velocity = direction * SPEED
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
