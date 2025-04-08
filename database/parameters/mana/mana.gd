class_name Mana
extends Parameter

signal depleted()


func use(amount: float) -> void:
	_modifiers -= amount
	_update_value()


func restore(amount: float) -> void:
	_modifiers += amount
	_update_value()


func is_depleted() -> bool:
	return _value <= 0


func _update_value() -> void:
	if _value <= 0:
		depleted.emit()

	super()
