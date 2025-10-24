extends Area2D

var speed = 400
var direction = Vector2.ZERO
var damage = 15

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta

func set_direction(dir: Vector2):
	direction = dir.normalized()
	# Rotate the sprite to face the direction
	rotation = direction.angle()

func _on_body_entered(body):
	if body.has_method("player"):
		# Deal damage to player here
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	elif not body.has_method("enemy"):
		# Hit wall or other obstacle
		queue_free()

# Auto-destroy after 5 seconds to prevent memory leaks
func _on_timer_timeout():
	queue_free()
