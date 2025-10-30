extends Resource

class_name Inventory

@export var items: Array[InventoryItem]

func insert(item: InventoryItem):
	if item:
		items.append(item)
		print(items)
		
