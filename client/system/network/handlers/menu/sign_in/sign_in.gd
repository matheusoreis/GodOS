extends Node


@export_group("References")
@export var sign_in_ui: SignInUi
@export var actor_list_ui: ActorListUi


func _ready() -> void:
	Network.handlers = [
		[Packets.SIGN_IN, _handle_sign_in]
	]


func _handle_sign_in(data: Dictionary) -> void:
	sign_in_ui.set_form_interactive(true)

	if not data.get("success", false):
		Alert.show(data.get("message", "Erro ao entrar."))
		return

	var account = data.get("account")
	if account == null:
		Alert.show("Erro! Os dados da conta não foram recebidos.")
		return

	Globals.account = account

	var message = data.get("message")
	if message != null:
		Alert.show(message)

	sign_in_ui.hide()
	actor_list_ui.show()

	Network.send_packet(Packets.ACTOR_LIST, {})
