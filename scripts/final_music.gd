extends Area2D

# Get reference to the audio player
@onready var music_player = get_node("/root/Tutorial/IgorotVillage/Area2D/finalMusic")

func _ready():
	# Connect the signal when something enters this area
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if it's the player that entered
	if body.name == "Lam-Ang":
		music_player.play()
