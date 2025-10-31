extends Resource

class_name Inventory

signal updated

@export var slots: Array[InventorySlot]

func insert(item):
	var itemSlots = slots.filter(func(slot): return slot.item != null and slot.item.name == item.name)
	if !itemSlots.is_empty():
		itemSlots[0].amount += 1
	else:
		var emptySlots = slots.filter(func(slot): return slot.item == null)
		if !emptySlots.is_empty():
			emptySlots[0].item = item
			emptySlots[0].amount = 1
	updated.emit()
