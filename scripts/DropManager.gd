extends Node

var XP_ORB_SCENE = preload("res://scenes/Drops/XPOrb.tscn") 
var COIN_SCENE = preload("res://scenes/Drops/CoinDrop.tscn") 

var HEALTH_POTION_RESOURCE = preload("res://Inventory/Item/lifepot.tres")
var ENERGY_POTION_RESOURCE = preload("res://Inventory/Item/energypot.tres")

var dropMultiplierMin = 1.0
var dropMultiplierMax = 2.0

func drop_xp(position: Vector2, xpAmount: int, dropChance: float = 1.0) -> void:
	if randf() <= dropChance:
		var orb = XP_ORB_SCENE.instantiate()
		
		var multiplier = randf_range(dropMultiplierMin, dropMultiplierMax)
		var finalAmount = int(round(xpAmount * multiplier))
		
		orb.xp_amount = finalAmount
		orb.global_position = position
		get_tree().current_scene.call_deferred("add_child", orb)
		
		print("Drop XP orb: ", finalAmount, "(x", multiplier, ")")
	else:
		print("XP drop failed (chance ", dropChance, ")")
		
func drop_coin(position: Vector2, coinAmount: int, dropChance: float = 1.0) -> void:
	if randf() <= dropChance:
		var coin = COIN_SCENE.instantiate()
		
		var multiplier = randf_range(dropMultiplierMin, dropMultiplierMax)
		var finalAmount = int(round(coinAmount * multiplier))
		
		coin.coin_amount = finalAmount
		coin.global_position = position
		get_tree().current_scene.call_deferred("add_child", coin)
		
		print("Drop Coin: ", finalAmount, "(x", multiplier, ")")
	else:
		print("Coin drop failed (chance ", dropChance, ")")
	
func drop_items(type: String, position: Vector2, dropChance: float) -> void:
	if randf() > dropChance:
		return
	
	match type:
		"healthPot":
			var healthItem = HEALTH_POTION_RESOURCE.duplicate()
			
			if healthItem.scene:
				var dropScene = healthItem.scene.instantiate()
				dropScene.global_position = position
				dropScene.itemResource = healthItem
				get_tree().current_scene.call_deferred("add_child", dropScene)
			else:
				print("no health scene")
		"energyPot":
			var energyItem = ENERGY_POTION_RESOURCE.duplicate()
			
			if energyItem.scene:
				var dropScene = energyItem.scene.instantiate()
				dropScene.global_position = position
				dropScene.itemResource = energyItem
				get_tree().current_scene.call_deferred("add_child", dropScene)
			else:
				print("no energy scene")
