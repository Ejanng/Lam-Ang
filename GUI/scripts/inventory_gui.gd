extends Control

signal opened
signal closed

var isOpen: bool = false

@onready var inventory: Inventory = preload("res://Inventory/Item/playerInventory.tres")
@onready var itemStackGuiClass = preload("res://GUI/scenes/item_stack_gui.tscn")
@onready var hotbarSlots: Array = $NinePatchRect/HBoxContainer.get_children()
@onready var artifactSlots: Array = $NinePatchRect/GridContainer2.get_children()
@onready var slots: Array = hotbarSlots + $NinePatchRect/GridContainer.get_children() + artifactSlots

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
	update_artifact_buffs()
	

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
	update_artifact_buffs()
	
	oldIndex = slot.index

func insertItemInSlot(slot):
	var item = itemInHand
	
	if item.inventorySlot.item.isConsumable and artifactSlots.has(slot):
		print(item.inventorySlot.item.name + " is consumable!")
		return
	
	remove_child(itemInHand)
	itemInHand = null
	
	slot.insert(item)
	
	oldIndex = -1
	update_artifact_buffs()
	
func swapItems(slot):
	var tempItem = slot.takeItem()
	var inv_item = tempItem.inventorySlot.item
	
	# Check if the old slot was from artifactsSlot
	var fromArtifact = false
	if oldIndex >= 0 and oldIndex < slots.size():
		var previousSlot = slots[oldIndex]
		if artifactSlots.has(previousSlot):
			fromArtifact = true
	
	# Example logic: prevent swapping consumable items into artifact slots
	if fromArtifact and inv_item.isConsumable:
		print("❌ Cannot swap a consumable item from artifact slot!")
		slot.insert(tempItem)  # put it back
		return
	
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

func update_artifact_buffs():
	var total_strength = 0.0
	var total_health = 0.0
	var total_speed = 0.0
	var total_energy = 0.0
	var total_def = 0.0
	var total_crit_dmg = 0.0
	var total_crit_chance = 0.0

	# Loop through all artifact slots
	for slot in artifactSlots:
		if slot.itemStackGui and slot.itemStackGui.inventorySlot and slot.itemStackGui.inventorySlot.item:
			var item = slot.itemStackGui.inventorySlot.item
			
			# Only apply buffs if not consumable
			if !item.isConsumable:
				total_strength += item.buffAttack
				total_health += item.buffHealth
				total_speed += item.buffSpeed
				total_energy += item.buffEnergy
				total_def += item.buffDefense
				total_crit_dmg += item.buffCritDamage
				total_crit_chance += item.buffCritChance
	
	# Update Global singleton values
	Global.strengthBuff = total_strength
	Global.healthBuff = total_health
	Global.speedBuff = total_speed
	Global.energyBuff = total_energy
	Global.defBuff = total_def
	Global.critDamageBuff = total_crit_dmg
	Global.critChanceBuff = total_crit_chance
