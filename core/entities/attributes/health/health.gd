class_name Health
extends Node2D

signal changed(value: int)
signal died()

@export_group("Variables")
@export var _min_health: int = 1
@export var _max_health: int = 10

var _health: int


func _initialize_attributes() -> void:
	_max_health = max(_max_health, _min_health)
	_health = randi_range(_min_health, _max_health)


func hurt(amount: int) -> void:
	_health -= amount
	_update_health()


func heal(amount: int) -> void:
	_health += amount
	_update_health()


func is_dead() -> bool:
	return _health <= 0


func get_health() -> int:
	return _health


func _update_health() -> void:
	_health = clamp(_health, 0, _max_health)
	changed.emit(_health)

	if _health <= 0:
		died.emit()
