extends Control

signal opened
signal closed

var isOpen: bool = false

@onready var inventory: Inventory = preload("res://Inventory/Item/playerInventory.tres")
@onready var artifacts: Artifacts = preload("res://Inventory/Artifacts/playerArtifacts.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
@onready var artifact_slots: Array = $NinePatchRect2/GridContainer.get_children()

func _ready() -> void:
	update()

func update():
	for i in range(min(inventory.items.size(), slots.size())):
		slots[i].update(inventory.items[i])
		
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
