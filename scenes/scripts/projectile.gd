extends Area2D

var speed = 400
var direction = Vector2.ZERO
var damage = 15

func _ready():
	body_entered.connect(_on_body_entered)
	# Add a timer to auto-destroy after 5 seconds
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()

func _physics_process(delta):
	position += direction * speed * delta

func set_direction(dir: Vector2):
	direction = dir.normalized()
	rotation = direction.angle() + deg_to_rad(90)  # Adjust based on your sprite orientation

func _on_body_entered(body):
	if body.has_method("player"):
		# Deal damage to player
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()  # Destroy projectile after hitting player
	elif not body.has_method("enemy"):
		# Hit wall or other obstacle (not another enemy)
		queue_free()
