class_name BoundedQueue
extends RefCounted


var count: int:
	get: return _count


var _slots: Array
var _ecursor: int
var _dcursor: int
var _count: int


func _init(capacity: int):
	_slots = []
	_slots.resize(capacity)

	_ecursor = 0
	_dcursor = -1


func enqueue(value: Variant) -> Error:
	if _ecursor == -1:
		return FAILED

	if _dcursor == -1:
		_dcursor = _ecursor

	_slots[_ecursor] = value
	_ecursor += 1
	_count += 1

	if _ecursor == _slots.size():
		_ecursor = -1 if _dcursor == 0 else 0
	elif _slots[_ecursor] != null:
		_ecursor = -1

	return OK


func dequeue() -> Variant:
	if _dcursor == -1:
		return null

	if _ecursor == -1:
		_ecursor = _dcursor

	var value = _slots[_dcursor]
	_slots[_dcursor] = null
	_dcursor += 1
	_count -= 1

	if _dcursor == _slots.size():
		_dcursor = -1 if _ecursor == 0 else 0
	elif _slots[_dcursor] == null:
		_dcursor = -1

	return value


func clear() -> void:
	_slots.fill(null)
	_count = 0
	_ecursor = 0
	_dcursor = -1
