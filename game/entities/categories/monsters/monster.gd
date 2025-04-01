class_name Monster
extends Entity


@export_group("Objects")
@export var _aggro: Aggro


@export_group("Attributes")
@export var min_health: int = 1
@export var max_health: int = 10

@export var min_mana: int = 1
@export var max_mana: int = 10

@export var min_damage: int = 1
@export var max_damage: int = 10

@export var min_defense: int = 1
@export var max_defense: int = 10

@export var min_speed: int = 1
@export var max_speed: int = 10

@export var min_aggro_radius: int = 1
@export var max_aggro_radius: int = 10

@export var min_coins: int = 1
@export var max_coins: int = 10


var health: int
var mana: int
var damage: int
var defense: int
var speed: int
var aggro_radius: int
var coins: int


func _ready() -> void:
	health = randi_range(min_health, max_health)
	mana = randi_range(min_mana, max_mana)
	damage = randi_range(min_damage, max_damage)
	defense = randi_range(min_defense, max_defense)
	speed = randi_range(min_speed, max_speed)
	aggro_radius = randi_range(min_aggro_radius, max_aggro_radius)
	coins = randi_range(min_coins, max_coins)

	_aggro.set_aggro_radius(aggro_radius)
