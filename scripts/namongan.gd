extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@export var player: CharacterBody2D  # Assign the player node in the inspector

var is_talking = false
var default_direction = "down"  # NPC faces south by default

func _ready():
	# Set initial idle animation facing south
	play_idle_animation(default_direction)

func _process(_delta):
	if is_talking and player:
		face_player()

func play_idle_animation(direction: String):
	match direction:
		"up":
			animated_sprite.play("idle_up")
		"down":
			animated_sprite.play("idle_down")
		"left":
			animated_sprite.play("idle_side")
			animated_sprite.flip_h = true  # Flip to face left
		"right":
			animated_sprite.play("idle_side")
			animated_sprite.flip_h = false  # Face right

func face_player():
	if not player:
		return
	
	var direction_to_player = global_position.direction_to(player.global_position)
	
	# Determine which direction to face based on player position
	if abs(direction_to_player.x) > abs(direction_to_player.y):
		# Player is more to the left or right
		if direction_to_player.x > 0:
			play_idle_animation("right")
		else:
			play_idle_animation("left")
	else:
		# Player is more above or below
		if direction_to_player.y > 0:
			play_idle_animation("down")
		else:
			play_idle_animation("up")

func start_conversation():
	is_talking = true
	face_player()

func end_conversation():
	is_talking = false
	# Return to default facing direction (south)
	play_idle_animation(default_direction)
