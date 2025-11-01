extends Control

signal opened
signal closed

var isOpen: bool = false

@onready var artifacts: Artifacts = preload("res://Inventory/Artifacts/playerArtifacts.tres")
@onready var artifact_slots: Array = $NinePatchRect2/Artifacts.get_children()

var itemInHand: ArtifactStackGui = null
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
		slot.pressed.connect(Callable(self, "onArtifactSlotClicked").bind(slot))

func update():
	for i in range(min(artifacts.slots.size(), artifact_slots.size())):
		var artifact_item: ArtifactsItem = artifacts.slots[i].item
		if artifact_item:
			var stack_gui = ArtifactStackGui.new()   # no arguments
			stack_gui.artifact = artifact_item       # set the resource property manually
			artifact_slots[i].insert(stack_gui)
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
	# Case 1: Empty slot and holding an item
	if slot.isEmpty():
		if itemInHand:
			insertArtifactInSlot(slot)
		return

	# Case 2: Slot has item and not holding any
	if !itemInHand:
		takeArtifactFromSlot(slot)
		return

	# Case 3: Slot has item and we are holding another (swap)
	swapArtifacts(slot)

func takeArtifactFromSlot(slot):
	itemInHand = slot.take_item()  # returns ArtifactStackGui
	oldIndex = slot.index
	print("Picked up:", itemInHand.artifact.name)

func insertArtifactInSlot(slot):
	if !(itemInHand is ArtifactStackGui):
		print("Only ArtifactStackGui can be placed here.")
		return

	slot.insert(itemInHand)
	artifacts.items[slot.index].item = itemInHand.artifact

	print("Placed artifact:", itemInHand.artifact.name)
	itemInHand = null
	oldIndex = -1
	update()

func swapArtifacts(slot):
	var temp: ArtifactStackGui = slot.take_item()
	insertArtifactInSlot(slot)
	itemInHand = temp
	oldIndex = slot.index
	update()

func putArtifactBack():
	if locked: return
	locked = true

	if oldIndex < 0:
		var emptySlots = artifact_slots.filter(func(s): return s.isEmpty())
		if emptySlots.is_empty():
			print("No empty slot to return artifact.")
			locked = false
			return
		oldIndex = emptySlots[0].index

	var targetSlot = artifact_slots[oldIndex]
	insertArtifactInSlot(targetSlot)
	itemInHand = null
	locked = false

func _input(event):
	if itemInHand and !locked and Input.is_action_just_pressed("rightClick"):
		putArtifactBack()
