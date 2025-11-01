extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
@export var auto_trigger: bool = false
var has_triggered: bool = false
var dialogue_active: bool = false

func _ready() -> void:
	if auto_trigger:
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Only trigger once and ignore repeated space presses
	if has_triggered or dialogue_active:
		print("Dialogue already running or triggered. Ignoring.")
		return

	if body.is_in_group("player") or body.name == "Lam-Ang":
		print("Player entered trigger zone.")
		has_triggered = true
		action()
	else:
		print("Non-player entered; ignoring.")


func action() -> void:
	var parent_name = get_parent().name
	var player = get_tree().get_root().find_child("Lam-Ang", true, false)

	dialogue_active = true  # ✅ Prevent multiple triggers while active

	if player:
		print("Disabling player movement.")
		player.can_move = false
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)

	# Dynamically assign dialogue start node based on parent name
	match parent_name:
		"Namongan":
			dialogue_start = "namongan_start"
		"WoundedVillager":
			dialogue_start = "wounded_villager_start"
		"InternalMonologue1":
			dialogue_start = "internal_monologue_1_start"
		"IgorotVillage":
			dialogue_start = "igorot_village_start"
		"NamonganMain1":
			dialogue_start = "lam_ang_scene1_start"
		"Act1Scene2":
			dialogue_start = "lam_ang_scene2_start"
		"Namongan&Pets":
			dialogue_start = "act2_scene1_homecoming_start"

	# ✅ Start the dialogue safely
	print("Starting dialogue: ", dialogue_start)
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)

	await DialogueManager.dialogue_ended

	if player:
		print("Re-enabling player movement.")
		player.can_move = true
		player.set_physics_process(true)

	dialogue_active = false
	print("Dialogue finished.")
