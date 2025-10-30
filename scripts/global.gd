extends Node

const MAX_HEALTH = 1000
const MAX_ENERGY = 70

var health = MAX_HEALTH
var energy = MAX_ENERGY
var damage = 20

var playerCurrentAttack = false
var player_chase = false

var playerXP = 0
var xpToNextLevel = 100
var playerCoin = 0
var playerLevel = 0

# character stats
var addDef = 0          # multiplier for health e.g health x def, to make the player can withstand longer 			
var addStrength = 0		# added dmg for player to deal in enemy
var addEnergy = 0		# added energy for player
var addHealth = 0
var addSpeed = 0

var isNameStat1 = false
var isNameStat2 = false

var mapBounds = Rect2(0,0,1024,2048)

# recalculated variable
var playerHealth = health + addHealth
var playerEnergy = energy + addEnergy
var playerDamage = damage + addStrength
