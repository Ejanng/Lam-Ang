extends Area2D

var entered = false

func _on_body_entered(body: PhysicsBody2D) -> void:
	if body.name == "Lam-Ang":
		entered = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Lam-Ang":
		entered = false
	
func _process(_sdelta):
	if entered == true:
		get_tree().change_scene_to_file("res://scenes/Tutorial/Scene2_2.tscn")
