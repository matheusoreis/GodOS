class_name Defense
extends Node2D

signal changed(value: float)

@export_group("Variables")
@export var _min_defense: float = 1.0
@export var _max_defense: float = 10.0

var _base_defense: float
var _modifiers: float = 0.0
var _defense: float


func _initialize_attributes() -> void:
	_max_defense = max(_max_defense, _min_defense)
	_base_defense = randf_range(_min_defense, _max_defense)
	_update_defense()


func modify(amount: float) -> void:
	_modifiers += amount
	_update_defense()


func reset() -> void:
	_modifiers = 0.0
	_update_defense()


func get_defense() -> float:
	return _defense


func _update_defense() -> void:
	_defense = max(_base_defense + _modifiers, 0)
	changed.emit(_defense)
