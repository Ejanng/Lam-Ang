extends Control

signal opened
signal closed

var isOpen: bool = false

@onready var artifacts: Artifacts = preload("res://Inventory/Artifacts/playerArtifacts.tres")
@onready var artifact_slots: Array = $NinePatchRect2/GridContainer.get_children()

var itemInHand: ArtifactsItem
var oldIndex: int = -1
var locked: bool = false	# prevent input during animation/tween

func _ready() -> void:
	connectSlots()
	update()

func connectSlots():
	if locked: return
	
	for i in range(artifact_slots.size()):
		var slot = artifact_slots[i]
		slot.index = i
		
		var callable = Callable(onArtifactSlotClicked)
		callable = callable.bind(slot)
		slot.pressed.connect(callable)

func update():
	for i in range(min(artifacts.items.size(), artifact_slots.size())):
		var item: ArtifactsItem = artifacts.items[i]
		if item:
			artifact_slots[i].insert(item)
		else:
			artifact_slots[i].clear()

func open():
	visible = true
	isOpen = true
	opened.emit()
	
func close():
	visible = false
	isOpen = false
	closed.emit()

func onArtifactSlotClicked(slot):
	if slot.isEmpty():
		if !itemInHand: return
		insertArtifactInSlot(slot)
		return
	
	if !itemInHand:
		takeArtifactFromSlot(slot)
		return
	
	# prevent stacking, only allow swapping
	swapArtifacts(slot)

func takeArtifactFromSlot(slot):
	itemInHand = slot.takeItem()
	add_child(itemInHand)
	updateItemInHand()
	oldIndex = slot.index

func insertArtifactInSlot(slot):
	if !(itemInHand is ArtifactsItem):
		print("Only artifacts can be placed here.")
		return
		
	remove_child(itemInHand)
	slot.insert(itemInHand)
	
	artifacts.items[slot.index] = itemInHand
	itemInHand = null
	oldIndex = -1

func swapArtifacts(slot):
	var temp = slot.takeItem()
	insertArtifactInSlot(slot)
	itemInHand = temp
	add_child(itemInHand)
	updateItemInHand()

func updateItemInHand():
	if !itemInHand: return
	itemInHand.global_position = get_global_mouse_position() - itemInHand.size / 2

func putArtifactBack():
	locked = true
	if oldIndex < 0:
		var emptySlots = artifact_slots.filter(func (s): return s.isEmpty())
		if emptySlots.is_empty(): return
		oldIndex = emptySlots[0].index
		
	var targetSlot = artifact_slots[oldIndex]
	insertArtifactInSlot(targetSlot)
	locked = false

func _input(event):
	if itemInHand and !locked and Input.is_action_pressed("rightClick"):
		putArtifactBack()
	updateItemInHand()
