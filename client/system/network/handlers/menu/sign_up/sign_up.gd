extends Node


@export_group("References")
@export var sign_up_ui: SignUpUi
@export var sign_in_ui: SignInUi


func _ready() -> void:
	Network.handlers = [
		[Packets.SIGN_UP, _handle_sign_up]
	]


func _handle_sign_up(data: Dictionary) -> void:
	sign_up_ui.set_form_interactive(true)

	if not data.get("success", false):
		Alert.show(data.get("message", "Erro ao criar a conta."))
		return

	var message = data.get("message", null)
	if message != null:
		Alert.show(message)

	sign_up_ui.hide()
	sign_in_ui.show()
