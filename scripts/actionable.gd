extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
@export var auto_trigger: bool = false 
var has_triggered: bool = false

func _ready() -> void:
	if auto_trigger:
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if it's the player entering
	if has_triggered:
		print("Already triggered, returning")
		return
		
	if body.is_in_group("player") or body.name == "Lam-Ang":  # Adjust based on your player node name
		print("Player detected! Triggering dialogue")
		has_triggered = true
		action()
	else:
		print("Not the player")
		
func action() -> void:
	var parent_name = get_parent().name
	
	var player = get_tree().get_root().find_child("Lam-Ang", true, false)
	print("Player found: ", player)
	if player:
		print("Setting can_move and canMove to false")
		player.can_move = false
		player.canMove = false
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)
		print("can_move is now: ", player.can_move)
		print("canMove is now: ", player.canMove)
	
	# Modify dialogue_start based on parent
	match parent_name:
		# Tutorial
		"Namongan":
			dialogue_start = "namongan_start"
		"WoundedVillager":
			dialogue_start = "wounded_villager_start"
		"InternalMonologue1":
			dialogue_start = "internal_monologue_1_start"
		"IgorotVillage":
			dialogue_start = "igorot_village_start"
			
		# Main Story
		"NamonganMain1":
			dialogue_start = "lam_ang_scene1_start"
		"Act1Scene2":
			dialogue_start = "lam_ang_scene2_start"
		"Namongan&Pets":
			dialogue_start = "act2_scene1_homecoming_start"
			

	
	# Start the dialogue
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)

	await DialogueManager.dialogue_ended
	if player:
		print("Re-enabling movement")
		player.can_move = true
		player.canMove = true
		player.set_physics_process(true)
		
