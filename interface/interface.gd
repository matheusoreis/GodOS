class_name Interface
extends Node


func _ready() -> void:
	self.gui_input.connect(
		func(ev: InputEvent):
			if ev is InputEventMouseButton:
				self.get_parent().move_child(self, self.get_parent().get_child_count() - 1)
	)

	for child in get_children() as Array[Node]:
		_change_mouse_filter(child)


func _change_mouse_filter(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_PASS
	for child in control.get_children() as Array[Node]:
		_change_mouse_filter(child)
