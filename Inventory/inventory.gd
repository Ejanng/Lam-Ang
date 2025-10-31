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
	
	slots[index] = InventorySlot.new()
	
func insertSlot(index: int, inventorySlot: InventorySlot):
	slots[index] = inventorySlot
