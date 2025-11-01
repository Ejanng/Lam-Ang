extends CharacterBody2D

var is_following_player = false
var player: CharacterBody2D = null
const SPEED = 150

func _physics_process(delta: float) -> void:
	if is_following_player:
		var direction = (player.position - position).normalized()
		velocity = direction * SPEED
		move_and_slide()
