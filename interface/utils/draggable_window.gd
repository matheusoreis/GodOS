extends Control


@export var _target_node: NodePath
var _drag_offset: Vector2 = Vector2.ZERO
var _is_dragging: bool = false
var _target: Control = null


func _ready() -> void:
	_target = get_node(_target_node)


func _gui_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return

	if not event.pressed or not _target:
		_is_dragging = false
		return

	_target.get_parent().move_child(_target, _target.get_parent().get_child_count() - 1)
	_drag_offset = event.position
	_is_dragging = true

	if event is InputEventMouseMotion and _is_dragging and _target:
		_target.global_position += event.relative


func _process(_delta: float) -> void:
	if not _is_dragging or not _target:
		return

	var mouse_position = get_global_mouse_position() - _drag_offset
	var target_size = _target.size
	var parent_rect = get_viewport_rect()

	mouse_position.x = clamp(mouse_position.x, 0, parent_rect.size.x - target_size.x)
	mouse_position.y = clamp(mouse_position.y, 0, parent_rect.size.y - target_size.y)

	_target.global_position = mouse_position
