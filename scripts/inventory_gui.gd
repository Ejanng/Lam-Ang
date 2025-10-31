extends Control

signal opened
signal closed

var isOpen: bool = false

@onready var inventory: Inventory = preload("res://Inventory/Item/playerInventory.tres")
@onready var artifacts: Artifacts = preload("res://Inventory/Artifacts/playerArtifacts.tres")
@onready var itemStackGuiClass = preload("res://GUI/itemStackGui.tscn")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
@onready var artifact_slots: Array = $NinePatchRect2/GridContainer.get_children()

var itemInHand: ItemStackGui

func _ready() -> void:
	connectSlots()
	inventory.updated.connect(update)
	update()
	
func connectSlots():
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		
		var callable = Callable(onSlotClicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		var inventorySlot: InventorySlot = inventory.slots[i]
		
		if !inventorySlot.item: continue
		
		var itemStackGui: ItemStackGui = slots[i].itemStackGui
		if !itemStackGui:
			itemStackGui = itemStackGuiClass.instantiate()
			slots[i].insert(itemStackGui)
		
		itemStackGui.inventorySlot = inventorySlot
		itemStackGui.update()
		
	for i in range(min(artifacts.items.size(), artifact_slots.size())):
		artifact_slots[i].update(artifacts.items[i])

func open():
	visible = true
	isOpen = true
	opened.emit()
	
func close():
	visible = false
	isOpen = false
	closed.emit()

func onSlotClicked(slot):
	if slot.isEmpty():
		if !itemInHand: return
		
		insertItemInSlot(slot)
		return
	
	if !itemInHand:
		takeItemFromSlot(slot)
		return
		
	swapItems(slot)
	
func takeItemFromSlot(slot):
	itemInHand = slot.takeItem()
	add_child(itemInHand)
	updateItemInHand()

func insertItemInSlot(slot):
	var item = itemInHand
	
	remove_child(itemInHand)
	itemInHand = null
	
	slot.insert(item)
	
func swapItems(slot):
	var tempItem = slot.takeItem()
	
	insertItemInSlot(slot)
	
	itemInHand = tempItem
	add_child(itemInHand)
	updateItemInHand()

func updateItemInHand():
	if !itemInHand: return
	itemInHand.global_position = get_global_mouse_position() - itemInHand.size / 2
	
func _input(event):
	updateItemInHand()
