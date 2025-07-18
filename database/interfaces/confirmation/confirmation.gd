class_name ConfirmationInterface
extends PanelContainer


signal on_confirm_pressed()


@export_category("Nodes")
@export var _message: Label
@export var _confirm_button: Button
@export var _back_button: Button


func _ready() -> void:
	_confirm_button.pressed.connect(_on_confirm_button_pressed)
	_back_button.pressed.connect(_on_back_button_pressed)


func set_message(message: String) -> void:
	_message.text = message


func _on_back_button_pressed() -> void:
	queue_free()


func _on_confirm_button_pressed() -> void:
	on_confirm_pressed.emit()
	queue_free()
