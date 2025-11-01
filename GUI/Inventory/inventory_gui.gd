extends Control

signal opened
signal closed

var isOpen: bool = false

@onready var inventory: Inventory = preload("res://Inventory/Item/playerInventory.tres")
@onready var artifacts: Artifacts = preload("res://Inventory/Artifacts/playerArtifacts.tres")
@onready var itemStackGuiClass = preload("res://GUI/Inventory/itemStackGui.tscn")
@onready var hotbarSlots: Array = $NinePatchRect/HBoxContainer.get_children()
@onready var slots: Array = hotbarSlots + $NinePatchRect/GridContainer.get_children()
var itemInHand: ItemStackGui
var oldIndex: int = -1
var locked: bool = false		#used for if there is animtion tween

func _ready() -> void:
	connectSlots()
	inventory.updated.connect(update)
	update()
	
func connectSlots():
	if locked: return
	
	for i in range(slots.size()):
		var slot = slots[i]
		slot.index = i
		
		var callable = Callable(onSlotClicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

func update():
	for i in range(min(inventory.slots.size(), slots.size())):
		var inventorySlot: InventorySlot = inventory.slots[i]
		
		if !inventorySlot.item: 
			slots[i].clear()
			continue
		
		var itemStackGui: ItemStackGui = slots[i].itemStackGui
		if !itemStackGui:
			itemStackGui = itemStackGuiClass.instantiate()
			slots[i].insert(itemStackGui)
		
		itemStackGui.inventorySlot = inventorySlot
		itemStackGui.update()

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
		
	if slot.itemStackGui.inventorySlot.item.name == itemInHand.inventorySlot.item.name:
		stackItems(slot)
		return
	
	swapItems(slot)
	
func takeItemFromSlot(slot):
	itemInHand = slot.takeItem()
	add_child(itemInHand)
	updateItemInHand()
	
	oldIndex = slot.index

func insertItemInSlot(slot):
	var item = itemInHand
	
	remove_child(itemInHand)
	itemInHand = null
	
	slot.insert(item)
	
	oldIndex = -1
	
func swapItems(slot):
	var tempItem = slot.takeItem()
	
	insertItemInSlot(slot)
	
	itemInHand = tempItem
	add_child(itemInHand)
	updateItemInHand()

func stackItems(slot):
	var slotItem: ItemStackGui = slot.itemStackGui
	var maxAmount = slotItem.inventorySlot.item.maxAmountPerStack
	var totalAmount = slotItem.inventorySlot.amount + itemInHand.inventorySlot.amount
	
	if slotItem.inventorySlot.amount == maxAmount:
		swapItems(slot)
		return
		
	if totalAmount <= maxAmount:
		slotItem.inventorySlot.amount = totalAmount
		remove_child(itemInHand)
		itemInHand = null
		oldIndex -1
	else:
		slotItem.inventorySlot.amount = maxAmount
		itemInHand.inventorySlot.amount = totalAmount - maxAmount
		
	slotItem.update()
	if itemInHand: itemInHand.update()
	inventory.updated.emit()

func updateItemInHand():
	if !itemInHand: return
	itemInHand.global_position = get_global_mouse_position() - itemInHand.size / 2
	
func putItemBack():
	locked = true
	if oldIndex < 0:
		var emptySlots = slots.filter(func (s): return s.isEmpty())
		if emptySlots.is_empty(): return
		
		oldIndex = emptySlots[0].index
		
	var targetSlot = slots[oldIndex]
	insertItemInSlot(targetSlot)
	locked = false
	
func _input(event):
	if itemInHand and !locked and Input.is_action_pressed("rightClick"):
		putItemBack()
		
	updateItemInHand()
