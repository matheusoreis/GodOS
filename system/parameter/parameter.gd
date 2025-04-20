class_name Parameter
extends Node2D

signal changed(value: int)
signal level_up(level: int)
signal level_down(level: int)

@export_group("Variables")
@export var _min_value: int = 0
@export var _max_value: int = 10
@export var _exp_per_level: int = 100
@export var _level_up_factor: int = 5

@export var _base_value: int
@export var _modifiers: int = 0
@export var _value: int
@export var _current_exp: int = 0
@export var _level: int = 1


func _ready() -> void:
	_initialize_attributes()


func _initialize_attributes() -> void:
	_base_value = randi_range(_min_value, _max_value)
	_update_value()


func modify(amount: int) -> void:
	_modifiers += amount
	_update_value()


func reset() -> void:
	_modifiers = 0
	_current_exp = 0
	_update_value()


func get_value() -> int:
	return _value


func get_level() -> int:
	return _level


func get_exp() -> int:
	return _current_exp


func get_exp_for_next_level() -> int:
	return _level * _exp_per_level


func add_exp(amount: int) -> void:
	_current_exp += amount
	_check_level_up()
	_update_value()


func remove_exp(amount: int) -> void:
	_current_exp -= amount
	_check_level_down()
	_update_value()


func _check_level_up() -> void:
	if _current_exp >= get_exp_for_next_level():
		_level += 1
		# XP que sobra após subir de nível
		_current_exp -= get_exp_for_next_level()
		level_up.emit(_level)
		# Adiciona valor permanente ao parâmetro após level up
		_add_value_per_level()
		_update_value()


func _check_level_down() -> void:
	if _current_exp < 0:
		_level -= 1
		_current_exp = 0
		level_down.emit(_level)
		_update_value()


func _add_value_per_level() -> void:
	_base_value += _level_up_factor


func _update_value() -> void:
	_value = _base_value + _modifiers
	changed.emit(_value)
