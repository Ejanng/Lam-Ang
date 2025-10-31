extends Resource

class_name InventoryItem

@export var name: String = ""
@export var texture: Texture2D
@export var scene: PackedScene
@export var maxAmountPerStack: int = 10
@export var effectValue: float
@export var isConsumable: bool = true
