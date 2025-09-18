extends Camera2D


var zoom_levels := [1.0, 2.0, 3.0]
var current_index := 0


func _ready() -> void:
	_apply_zoom()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_change_zoom(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_change_zoom(-1)


func _change_zoom(direction: int) -> void:
	current_index = clamp(current_index + direction, 0, zoom_levels.size() - 1)
	_apply_zoom()


func _apply_zoom() -> void:
	var value = zoom_levels[current_index]
	zoom = Vector2(value, value)
