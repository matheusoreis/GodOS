class_name SignInInterface
extends Interface


@export_group("Objects")
@onready var _client: Client = $"../../Network/Client"
@onready var _close_button: Button = $content/top_bar/margin/close
@onready var _email_line: LineEdit = $content/margin/content/inputs/email
@onready var _password_line: LineEdit = $content/margin/content/inputs/password
@onready var _confirm_button: Button = $content/margin/content/buttons/confirm
@onready var _sign_up_button: Button = $content/margin/content/buttons/sign_up

@export_group("Variables")
@export var min_password_length: int = 6

var email_regex: String = "^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"


func _ready() -> void:
	super()

	if not _client:
		return

	_confirm_button.pressed.connect(
		_on_sign_in_pressed
	)

	_sign_up_button.pressed.connect(
		_on_sign_up_pressed
	)

	_password_line.text_changed.connect(
		func(new_text: String):
			_password_line.add_theme_color_override(
				"font_color", Color.RED if new_text.length() < min_password_length else Color.WHITE
			)
	)

	_email_line.text_changed.connect(
		func(new_text: String):
			var is_valid = RegEx.create_from_string(email_regex).search(new_text) != null
			_email_line.add_theme_color_override(
				"font_color", Color.RED if not is_valid else Color.WHITE
			)
	)

	_client.connected_to_server.connect(
		func():
			_confirm_button.disabled = false
			_sign_up_button.disabled = false
	)

	_client.connection_failed.connect(
		func():
			_confirm_button.disabled = true
			_sign_up_button.disabled = true
	)

	_client.server_disconnected.connect(
		func():
			_confirm_button.disabled = true
			_sign_up_button.disabled = true
	)


func _on_sign_in_pressed() -> void:
	var _email_line_text = _email_line.text
	var _password_line_text = _password_line.text

	if _email_line_text.is_empty() || _password_line_text.is_empty():
		print("Por favor, preencha todos os campos.")
		return

	_confirm_button.disabled = true
	_sign_up_button.disabled = true
	_close_button.disabled = true

	_request_login.rpc_id(1, _email_line_text, _password_line_text, Constants.version)


func _on_sign_up_pressed() -> void:
	WindowManager.hide_interface("sign_in")
	WindowManager.show_interface("sign_up")


func _reset_ui() -> void:
	_close_button.disabled = false
	_confirm_button.disabled = false
	_sign_up_button.disabled = false

	_email_line.clear()
	_password_line.clear()


@rpc("any_peer", "call_remote")
func _request_login(email: String, password: String, version: Vector3i) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	var error_messages: Array[String] = []

	if version != Constants.version:
		error_messages.append("O seu cliente está desatualizado!")
		_on_login_failed.rpc_id(sender_id, error_messages)
		return

	var endpoint = Env.backend_endpoint + "auth/sign-in"
	var headers := {
		"Content-Type": "application/json",
		"Authorization": Env.backend_token
	}
	var body := {
		"email": email,
		"password": password,
	}

	var result := await Fetch.fetch_json(HTTPClient.METHOD_POST, endpoint, body, headers)
	var status_code = result[1]
	var response_data = result[2]

	if status_code != 201:
		error_messages.append_array(Fetch.format_errors(response_data))
		_on_login_failed.rpc_id(sender_id, error_messages)
		return

	if Globals.users.has(sender_id):
		error_messages.append("Você já está autenticado no servidor!")
		_on_login_failed.rpc_id(sender_id, error_messages)
		return

	for existing_user in Globals.users.values():
		if existing_user["id"] == response_data["id"]:
			error_messages.append("Essa conta já está conectada ao servidor por outro dispositivo!")
			_on_login_failed.rpc_id(sender_id, error_messages)
			return

	var user: Dictionary = {
		"id": response_data["id"],
		"email": response_data["email"],
		"max_actors": response_data["max_actors"],
		"last_login": response_data["last_login"],
		"created_at": response_data["created_at"],
		"updated_at": response_data["updated_at"],
	}

	_on_login_success.rpc_id(sender_id, "Sucesso ao acessar o jogo!")


@rpc("authority", "call_local")
func _on_login_success(message: String) -> void:
	WindowManager.hide_interface("sign_in")
	WindowManager.show_interface("sign_up")

	ShowNotification.show([message])
	_reset_ui()


@rpc("authority", "call_local")
func _on_login_failed(messages: Array[String]) -> void:
	ShowNotification.show(messages)
	_reset_ui()
