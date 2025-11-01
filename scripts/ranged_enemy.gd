extends CharacterBody2D

const SPEED = 100  # Slower than melee enemy
var player_chase = false
var player = null
var health = 80  # Less health than melee
var canTakeDMG = true
var meleeDMG = 20
var can_shoot = true
var attack_range = 300  # Stop moving when within this range

@onready var anim = $AnimatedSprite2D
@onready var takeDMGCD = $take_dmg_cooldown
@onready var health_bar = $HealthBar
@onready var shoot_timer = $ShootTimer  # You'll add this


# Load the projectile scene
var projectile_scene = preload("res://scenes/Hostile/projectile.tscn")

func _ready() -> void:
	health_bar.max_value = health
	health_bar.value = health
	
	# Setup shoot timer if it doesn't exist
	#if not has_node("ShootTimer"):
		#var timer = Timer.new()
		#timer.name = "ShootTimer"
		#timer.wait_time = 2.0  # Shoot every 2 seconds
		#timer.one_shot = false
		#add_child(timer)
		#timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.wait_time = 2.0
	shoot_timer.one_shot = false
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start()

func _physics_process(delta: float) -> void:
	handle_movement()
	handle_shooting()
	deal_dmg()

func handle_movement():
	if player_chase and player:
		var distance_to_player = position.distance_to(player.position)
		
		# Keep distance from player (ranged behavior)
		if distance_to_player > attack_range:
			# Move closer
			position += (player.position - position) / SPEED
			anim.play("walk_side")
		elif distance_to_player < attack_range - 50:
			# Too close, back away
			position -= (player.position - position) / SPEED
			anim.play("walk_side")
		else:
			# In good range, stop and shoot
			anim.play("idle")
		
		# Flip sprite based on player position
		if (player.position.x - position.x) < 0:
			anim.flip_h = true
		else:
			anim.flip_h = false
	else:
		anim.play("idle")

func handle_shooting():
	if player_chase and player and can_shoot:
		shoot_projectile()
		can_shoot = false
		$ShootTimer.start()

func shoot_projectile():
	var projectile = projectile_scene.instantiate()
	# Spawn projectile at enemy position
	projectile.position = global_position
	
	# Calculate direction to player (8-directional)
	var direction = (player.global_position - global_position).normalized()
	direction = snap_to_8_directions(direction)
	
	projectile.set_direction(direction)
	
	# Add to scene tree (same level as enemy)
	get_parent().add_child(projectile)

func snap_to_8_directions(dir: Vector2) -> Vector2:
	# Get angle in degrees
	var angle = rad_to_deg(dir.angle())
	
	# Round to nearest 45 degrees
	var snapped_angle = round(angle / 45.0) * 45.0
	
	# Convert back to vector
	return Vector2.RIGHT.rotated(deg_to_rad(snapped_angle))

func _on_shoot_timer_timeout():
	can_shoot = true

func enemy():
	pass

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false

func deal_dmg():
	if Global.playerCurrentAttack == true:
		if player and position.distance_to(player.position) <= 50:
			if canTakeDMG:
				health -= meleeDMG
				health_bar.value = health
				takeDMGCD.start()
				canTakeDMG = false
				print("Player Deals DMG: ", meleeDMG, "\nEnemy Health: ", health)
			if health <= 0:
				self.queue_free()

func _on_take_dmg_cooldown_timeout() -> void:
	canTakeDMG = true
