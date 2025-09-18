class_name ConfirmationUi
extends Control


signal on_confirm_pressed()


@export var message_label: Label


func add_message(message: String) -> void:
	message_label.text = message


func _on_confirm_pressed() -> void:
	on_confirm_pressed.emit()
	queue_free()


func _on_back_pressed() -> void:
	queue_free()
