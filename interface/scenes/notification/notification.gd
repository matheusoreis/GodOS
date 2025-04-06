class_name NotificationUI extends Panel


@export_group("Objects")
@onready var message_label: Label = $panel/content/margin/content/message

@export_group("Variables")
@export var message: String = ""


func _ready() -> void:
	message_label.text = message


func _on_close_pressed() -> void:
	queue_free()


func _on_confirm_pressed() -> void:
	queue_free()
