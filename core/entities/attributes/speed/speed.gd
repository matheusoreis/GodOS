class_name Speed
extends Node2D

signal changed(value: float)

@export_group("Variables")
@export var _min_speed: float = 10.0
@export var _max_speed: float = 100.0


var _base_speed: float
var _modifiers: float = 0.0
var _speed: float


func _initialize_attributes() -> void:
	_max_speed = max(_max_speed, _min_speed)
	_base_speed = randf_range(_min_speed, _max_speed)
	_update_speed()


func modify(amount: float) -> void:
	_modifiers += amount
	_update_speed()


func reset() -> void:
	_modifiers = 0.0
	_update_speed()


func _update_speed() -> void:
	_speed = clamp(_base_speed + _modifiers, _min_speed, _max_speed)
	changed.emit(_speed)


func get_speed() -> float:
	return _speed
