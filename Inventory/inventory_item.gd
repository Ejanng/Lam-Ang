extends Resource

class_name InventoryItem

@export var name: String = ""
@export var texture: Texture2D
@export var scene: PackedScene
@export var maxAmountPerStack: int = 1
@export var effectValue: float
@export var isConsumable: bool
@export var buffDefense: float
@export var buffAttack: float
@export var buffSpeed: float
@export var buffHealth: float
@export var buffEnergy: float
@export var buffCritChance: float
@export var buffCritDamage: float
