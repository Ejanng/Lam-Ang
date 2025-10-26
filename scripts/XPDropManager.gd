extends Node

var XP_ORB_SCENE = preload("res://scenes/Drops/XPOrb.tscn") 
var COIN_SCENE = preload("res://scenes/Drops/XPOrb.tscn") 

var dropMultiplier = 1.0

func drop_xp(position: Vector2, xpAmount: int, dropChance: float = 1.0) -> void:
	var adjustedChance = clamp(dropChance * dropMultiplier, 0.0, 1.0)
	if randf() <= dropChance:
		var orb = XP_ORB_SCENE.instantiate()
		orb.xp_amount = xpAmount
		orb.global_position = position
		get_tree().current_scene.add_child(orb)
		
func drop_coin(position: Vector2, coinAmount: int, dropChance: float = 1.0) -> void:
	if randf() <= dropChance:
		var coin = COIN_SCENE.instantiate()
		coin.coin_amount = coinAmount
		coin.global_position = position
		get_tree().current_scene.add_child(coin)
	
