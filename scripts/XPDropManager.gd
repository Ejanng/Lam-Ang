extends Node

var XP_ORB_SCENE = preload("res://scenes/Drops/XPOrb.tscn") # load the xp orb tscn

func drop_xp(position: Vector2, xpAmount: int, dropChance: float = 1.0) -> void:
	if randf() <= dropChance:
		var orb = XP_ORB_SCENE.instantiate()
		orb.xp_amount = xpAmount
		orb.global_position = position
		get_tree().current_scene.add_child(orb)
		
	
