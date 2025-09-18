extends Node


signal on_confirmation_pressed()


var confirmation: ConfirmationUi


func show(message: String) -> void:
	var alert_scene: PackedScene = load("res://database/interfaces/shared/confirmation.tscn")
	confirmation = alert_scene.instantiate()
	confirmation.add_message(message)

	confirmation.on_confirm_pressed.connect(
		func ():
			on_confirmation_pressed.emit()
	)

	get_tree().current_scene.add_child(confirmation)
