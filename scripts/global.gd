extends Node

var MAX_HEALTH = 1000
var MAX_ENERGY = 70

var playerHealth = MAX_HEALTH
var playerEnergy = MAX_ENERGY
var damage = 20

var playerCurrentAttack = false
var player_chase = true

var playerXP = 0
var xpToNextLevel = 100
var playerCoin = 0
var playerLevel = 0

# drop effects
var healthPotion: float
var energyPotion: float

# artifacts slot
var isNameStat1 = false
var isNameStat2 = false

var mapBounds = Rect2(-1000, -1000 ,10000, 10000)

var currentWave: int
var moveingToNextWave: bool

var strengthBuff: float = 0.0
var healthBuff: float = 0.0
var speedBuff: float = 0.0
var energyBuff: float = 0.0
var defBuff: float = 0.0
var critDamageBuff: float = 0.0
var critChanceBuff: float = 0.0

var addSpeed = 150.0 + speedBuff
