extends Control

@export var sign_in_ui: SignInUi
@export var sign_up_ui: SignUpUi

func _ready() -> void:
	Network.logger.connect(_on_network_logger)
	
	Network.registry = [
		[Packets.SIGN_IN, _handle_sign_in],
		[Packets.SIGN_UP, _handle_sign_up],
	]
	
	Network.connect_to_host(Constants.host, Constants.port, Constants.secure)


func _on_network_logger(message: String) -> void:
	Alert.show(message)


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

	get_tree().change_scene_to_file("res://system/scenes/account/account.tscn")


func _handle_sign_up(data: Dictionary) -> void:
	sign_up_ui.set_form_interactive(true)

	if not data.get("success", false):
		Alert.show(data.get("message", "Erro ao criar a conta."))
		return

	var message = data.get("message")
	if message != null:
		Alert.show(message)

	sign_up_ui.hide()
	sign_in_ui.show()
