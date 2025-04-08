class_name Mana
extends Node2D

signal changed(value: int)
signal depleted()

@export_group("Variables")
@export var _min_mana: int = 0
@export var _max_mana: int = 100

var _mana: int


func _initialize_attributes() -> void:
	_max_mana = max(_max_mana, _min_mana)
	_mana = randi_range(_min_mana, _max_mana)
	_update_mana()


func use(amount: int) -> void:
	_mana -= amount
	_update_mana()

	if _mana <= 0:
		depleted.emit()


func restore(amount: int) -> void:
	_mana += amount
	_update_mana()


func is_depleted() -> bool:
	return _mana <= 0


func get_mana() -> int:
	return _mana


func _update_mana() -> void:
	_mana = clamp(_mana, _min_mana, _max_mana)
	changed.emit(_mana)
