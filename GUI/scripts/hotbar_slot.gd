extends Button

@onready var backgroundSprite:Sprite2D = $background
@onready var itemStackGui: ItemStackGui = $CenterContainer/Panel

func update_to_slot(slot: InventorySlot) -> void:
	if !slot.item:
		itemStackGui.visible = false
		backgroundSprite.frame = 0
		return
		
	itemStackGui.inventorySlot = slot
	itemStackGui.update()
	itemStackGui.visible = true
	backgroundSprite.frame = 1
