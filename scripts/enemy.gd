extends CharacterBody2D

const SPEED = 150
var player_chase = false
var player = null
@onready var anim = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	handle_movement()
		
	
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
