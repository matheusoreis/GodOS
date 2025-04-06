class_name ConfirmationUI extends Panel


signal confirmed()


@export_group("Objects")
@export var _message_label: Label
@export var confirm_button: Button
@export var _back_button: Button

@export_group("Variables")
var message: String = ""


func _ready() -> void:
	_message_label.text = message

	confirm_button.pressed.connect(
		func():
			confirmed.emit()
			queue_free()
	)

	_back_button.pressed.connect(
		func():
			queue_free()
	)
