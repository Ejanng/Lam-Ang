extends Area2D

var entered = false

func _on_body_entered(body: PhysicsBody2D) -> void:
	if body.name == "Lam-Ang":
		entered = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Lam-Ang":
		entered = false
	
func _process(_delta):
	if entered == true:
		SceneManager.change_scene_to("res://scenes/Tutorial/Scene3.tscn", "FromScene2_2")
