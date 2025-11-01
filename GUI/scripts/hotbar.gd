extends Panel

@onready var inventory: Inventory = preload("res://Inventory/Item/playerInventory.tres")
@onready var slots: Array = $Container.get_children()
@onready var selector: Sprite2D = $Sprite2D

var currentSelected: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	update()
	inventory.updated.connect(update)

func update():
	for i in range(slots.size()):
		var inventorySlot: InventorySlot = inventory.slots[i]
		slots[i].update_to_slot(inventorySlot)

func move_selector() -> void:
	currentSelected = (currentSelected + 1) % slots.size()
	selector.global_position = slots[currentSelected].global_position

func _unhandled_input(event) -> void:
	if event.is_action_pressed("use_item"):
		inventory.use_item_at_index(currentSelected)
		
	if event.is_action_pressed("move_selecttor"):
		move_selector()
