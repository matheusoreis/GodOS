class_name AlertUi
extends Control


@export var message_label: Label


func _on_confirm_pressed() -> void:
	queue_free()


func add_message(message: String ) -> void:
	message_label.text = message
