extends Node

const MAX_HEALTH = 1000
const MAX_ENERGY = 70

var playerHealth = MAX_HEALTH
var playerEnergy = MAX_ENERGY

var playerCurrentAttack = false
var player_chase = false

var playerXP = 0
var xpToNextLevel = 100
var playerCoin = 0
var playerLevel = 0

var mapBounds = Rect2(0,0,1024,2048)
