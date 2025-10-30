extends Area2D

@export var itemResource = preload("res://Inventory/Item/lifepot.tres")

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		var inv = body.inventory
		if inv and itemResource:
			inv.insert(itemResource.duplicate())
			queue_free()
		
