extends Control


@export_group("References")
@export var sign_in_ui: SignInUi
@export var sign_up_ui: SignUpUi


func _ready() -> void:
	Network.logger.connect(_on_network_logger)

	sign_in_ui.sign_up_pressed.connect(_show_sign_up_ui)
	sign_up_ui.sign_in_pressed.connect(_show_sign_in_ui)


func _on_network_logger(message: String) -> void:
	Alert.show(message)


func _show_sign_in_ui() -> void:
	sign_in_ui.show()


func _show_sign_up_ui() -> void:
	sign_up_ui.show()
