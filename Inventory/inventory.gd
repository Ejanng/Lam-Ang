extends Resource

class_name Inventory

signal updated

@export var slots: Array[InventorySlot]

func insert(item):
	var remaining = 1
	
	for slot in slots:
		if slot.item != null and slot.item.name == item.name:
			var spaceLeft = item.maxAmountPerStack - slot.amount
			if spaceLeft > 0:
				var toAdd = min(spaceLeft, remaining)
				slot.amount += toAdd
				remaining -= toAdd
				if remaining <= 0:
					updated.emit()
					return
	for slot in slots:
		if slot.item == null:
			slot.item = item
			slot.amount = min(item.maxAmountPerStack, remaining)
			remaining -= slot.amount
			if remaining <= 0:
				updated.emit()
				return
	
func removeSlot(inventorySlot: InventorySlot):
	var index = slots.find(inventorySlot)
	if index < 0: return
	
	remove_at_index(index)
	
func remove_at_index(index: int) -> void:
	slots[index] = InventorySlot.new()
	updated.emit()

func insertSlot(index: int, inventorySlot: InventorySlot):
	slots[index] = inventorySlot
	updated.emit()
	
func use_item_at_index(index: int) -> void:
	if index < 0 or index >= slots.size(): return
	var slot = slots[index]
	if !slot.item: return
	var item = slot.item
	
	if item.isConsumable:
		_apply_item_effect(item)
		
		if slot.amount > 1:
			slot.amount -= 1
			updated.emit()
			return
	
	remove_at_index(index)

func _apply_item_effect(item: InventoryItem):
	match item.name:
		"lifepot":
			Global.healthPotion = 0.0
			Global.healthPotion += item.effectValue
		"energypot":
			Global.energyPotion = 0.0
			Global.energyPotion += item.effectValue
		_:
			pass
