extends Node

const MAX_HEALTH = 1000
const MAX_ENERGY = 70

var playerHealth = MAX_HEALTH
var playerEnergy = MAX_ENERGY
var damage = 20

var playerCurrentAttack = false
var player_chase = false

var playerXP = 0
var xpToNextLevel = 100
var playerCoin = 0
var playerLevel = 0

# character stats 
var addDef = 0
var addStrength = 1000
var addEnergy = 0
var addHealth = 0
var addSpeed = 100
# drop effects
var healthPotion: float = 0
var energyPotion: float = 0

var mapBounds = Rect2(-1000, -1000 ,10000, 10000)

var currentWave: int
var moveingToNextWave: bool

# base player stats (no artifacts)
var base_def = 0.0
var base_speed = 0.0
var base_health = 0.0
var base_energy = 0.0
var base_strength = 0.0
var base_crit_chance = 0.0
var base_crit_dmg = 0.0

# artifact bonuses
var artifacts_def = 0.0
var artifacts_speed = 0.0
var artifacts_health = 0.0
var artifacts_energy = 0.0
var artifacts_strength = 0.0
var artifacts_crit_chance = 0.0
var artifacts_crit_dmg = 0.0

var active_artifacts: Array = []

func recalc_artifacts():
	artifacts_def = 0.0
	artifacts_speed = 0.0
	artifacts_health = 0.0
	artifacts_energy = 0.0
	artifacts_strength = 0.0
	artifacts_crit_chance = 0.0
	artifacts_crit_dmg = 0.0
	
	for artifact in active_artifacts:
		artifacts_def += artifact.defStat
		artifacts_speed += artifact.speedStat
		artifacts_health += artifact.healthStat
		artifacts_energy += artifact.energyStat
		artifacts_strength += artifact.strengthStat
		artifacts_crit_chance += artifact.critChanceStat
		artifacts_crit_dmg += artifact.critDMGChance
