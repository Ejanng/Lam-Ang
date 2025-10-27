extends Area2D

var entered = false

func _on_body_entered(body: PhysicsBody2D) -> void:
	entered = true
	
func _on_body_exited(body):
	entered = false
	
func _process(_delta):
	if entered == true:
		get_tree().change_scene_to_file("res://scenes/Tutorial/Scene2_1.tscn")
