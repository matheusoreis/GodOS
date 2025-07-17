class_name SignInInterface
extends PanelContainer


@export_category("Nodes")
@export var _email_input: LineEdit
@export var _password_input: LineEdit
@export var _sign_in_button: Button
@export var _sign_up_button: Button

@export_category("Messages")
@export var _invalid_email_message: String = "O email precisa ter ao menos 6 caracteres."
@export var _invalid_password_message: String = "A senha precisa ter ao menos 3 caracteres."
@export var _client_version_message: String = "Versão do cliente incompatível."
@export var _authenticated_message: String = "Você já está autenticado no servidor."

@export_category("References")
@export var _sign_up_interface: SignUpInterface
@export var _actor_list_interface: ActorListInterface


func _ready() -> void:
	_sign_in_button.pressed.connect(_on_sign_in_button_pressed)
	_sign_up_button.pressed.connect(_on_sign_up_button_pressed)


func _on_sign_in_button_pressed() -> void:
	var email: String = _email_input.text
	var password: String = _password_input.text

	if email.length() <= 6:
		Notification.show([_invalid_email_message])
		return

	if password.length() < 3:
		Notification.show([_invalid_password_message])
		return

	_email_input.editable = false
	_password_input.editable = false
	_sign_in_button.disabled = true
	_sign_up_button.disabled = true

	_sign_in_request.rpc_id(1, {
		"email": email,
		"password": password,
		"version": ClientConstants.version
	})


func _on_sign_up_button_pressed() -> void:
	_sign_up_interface.show()
	hide()


@rpc("any_peer")
func _sign_in_request(data: Dictionary) -> void:
	var peer_id = multiplayer.get_remote_sender_id()

	var email: String = data.email
	if email.length() <= 6:
		_respond_with_error(peer_id, [_invalid_email_message])
		return

	var password: String = data.password
	if password.length() < 3:
		_respond_with_error(peer_id, [_invalid_password_message])
		return

	var version: Vector3 = data.version
	if version != ServerConstants.version:
		_respond_with_error(peer_id, [_client_version_message])
		return

	var endpoint = ServerConstants.backend_endpoint + "account/sign-in"
	var headers := {"Content-Type": "application/json"}
	var body := {
		"email": email,
		"password": password
	}

	var result := await Fetch.fetch_json(HTTPClient.METHOD_POST, endpoint, body, headers)
	var status_code = result[1]
	var response_data = result[2]

	if status_code != 201:
		_respond_with_error(peer_id, Fetch.format_errors(response_data))
		return

	if ServerGlobals.users.has(peer_id):
		_respond_with_error(peer_id, [_authenticated_message])
		return

	ServerGlobals.users[peer_id] = response_data
	_sign_in_response.rpc_id(peer_id, [response_data, []])


func _respond_with_error(peer_id: int, message: Array) -> void:
	_sign_in_response.rpc_id(peer_id, [{}, message])


@rpc("authority")
func _sign_in_response(data: Array) -> void:
	var success: Dictionary = data[0]
	var error: Array = data[1]

	if not error.is_empty():
		reset_form()
		Notification.show(error)
		return

	ClientGlobals.user_data = success

	reset_form()
	hide()

	var max_actors = success["maxActors"]
	var actors = success["actors"]

	_actor_list_interface.show()
	_actor_list_interface.update_slots(max_actors, actors)


func reset_form() -> void:
	_email_input.clear()
	_password_input.clear()

	_email_input.editable = true
	_password_input.editable = true

	_sign_in_button.disabled = false
	_sign_up_button.disabled = false
