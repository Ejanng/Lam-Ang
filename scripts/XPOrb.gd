extends Area2D

var xp_amount: int

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("add_experience"):
		body.add_experience(xp_amount)
		queue_free()
