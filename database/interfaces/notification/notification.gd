class_name NotificationInterface
extends PanelContainer


@export var _message: Label
@export var _close_button: Button


func _ready() -> void:
	_close_button.pressed.connect(func(): queue_free())


func set_message(messages: Array) -> void:
	_message.text = "\n".join(messages)
