class_name Health
extends Parameter

signal died()


func hurt(amount: float) -> void:
	_modifiers -= amount
	_update_value()


func heal(amount: float) -> void:
	_modifiers += amount
	_update_value()


func is_dead() -> bool:
	return _value <= 0


func _update_value() -> void:
	if _value <= 0:
		died.emit()

	super()
