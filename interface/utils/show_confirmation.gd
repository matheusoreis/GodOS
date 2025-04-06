extends Node


signal confirmed()


func show(message: String) -> void:
	var confirmation_scene := load(
		"res://interface/scenes/confirmation/confirmation.tscn"
	) as PackedScene

	var confirmation_ui: ConfirmationUI = confirmation_scene.instantiate()
	confirmation_ui.message = message
	confirmation_ui.confirm_button.pressed.connect(
		func():
			confirmed.emit()
	)

	var menu: CanvasLayer = get_tree().root.get_node("Main/SharedInterface")
	menu.add_child(confirmation_ui)
