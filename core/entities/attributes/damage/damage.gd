class_name Damage
extends Node2D

signal changed(value: float)

@export_group("Variables")
@export var _min_damage: float = 5.0
@export var _max_damage: float = 20.0

var _base_damage: float
var _modifiers: float = 0.0
var _damage: float


func _initialize_attributes() -> void:
	_max_damage = max(_max_damage, _min_damage)
	_base_damage = randf_range(_min_damage, _max_damage)
	_update_damage()


func modify(amount: float) -> void:
	_modifiers += amount
	_update_damage()


func reset() -> void:
	_modifiers = 0.0
	_update_damage()


func get_damage() -> float:
	return _damage


func _update_damage() -> void:
	_damage = max(_base_damage + _modifiers, 0)
	changed.emit(_damage)
