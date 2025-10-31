extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

func action() -> void:
	var parent_name = get_parent().name
	
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
	
	# Start the dialogue
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
