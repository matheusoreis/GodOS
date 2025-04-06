class_name SignUpInterface
extends Interface


@export_group("Objects")
@onready var _client: Client = $"../../Network/Client"
@onready var _close_button: Button = $content/top_bar/margin/close
@onready var _email_line: LineEdit = $content/margin/content/inputs/email
@onready var _password_line: LineEdit = $content/margin/content/inputs/password
@onready var _re_password_line: LineEdit = $content/margin/content/inputs/re_password
@onready var _confirm_button: Button = $content/margin/content/buttons/confirm
@onready var _back_button: Button = $content/margin/content/buttons/back


@export_group("Variables")
@export var min_password_length: int = 6

var email_regex: String = "^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"


func _ready() -> void:
	super()

	# Conecta o sinal de "pressionado" do botão de confirmar
	_confirm_button.pressed.connect(
		func():
			var email_text = _email_line.text
			var password_text = _password_line.text
			var re_password_text = _re_password_line.text

			if email_text.is_empty() || password_text.is_empty() || re_password_text.is_empty():
				print("Por favor, preencha todos os campos.")
				return

			_confirm_button.disabled = true
			_back_button.disabled = true
			_close_button.disabled = true

			# Envia a requisição de sign up para o servidor
			_request_sign_up.rpc_id(1, email_text, password_text, re_password_text)
	)

	# Conecta o sinal de "pressionado" do botão de voltar
	_back_button.pressed.connect(
		func():
			WindowManager.hide_interface("sign_up")
			WindowManager.show_interface("sign_in")
	)

	# Valida o e-mail enquanto o usuário digita
	_email_line.text_changed.connect(
		func(new_text: String):
			var is_valid = RegEx.create_from_string(email_regex).search(new_text) != null
			_email_line.add_theme_color_override(
				"font_color", Color.RED if not is_valid else Color.WHITE
			)
	)

	# Valida a senha enquanto o usuário digita
	_password_line.text_changed.connect(
		_validate_passwords
	)

	# Valida a re senha enquanto o usuário digita
	_re_password_line.text_changed.connect(
		_validate_passwords
	)

	# Ativa os botões quando o cliente conectar ao servidor
	_client.connected_to_server.connect(
		func():
			_confirm_button.disabled = false
			_back_button.disabled = false
	)


func _validate_passwords(_new_text: String = "") -> void:
	var is_valid_length = _password_line.text.length() >= min_password_length
	_password_line.add_theme_color_override(
		"font_color", Color.RED if not is_valid_length else Color.WHITE
	)

	var passwords_match = _password_line.text == _re_password_line.text
	_re_password_line.add_theme_color_override(
		"font_color", Color.RED if not passwords_match else Color.WHITE
	)


func _reset_ui() -> void:
	_close_button.disabled = false
	_confirm_button.disabled = false
	_back_button.disabled = false

	_email_line.clear()
	_password_line.clear()
	_re_password_line.clear()


@rpc("any_peer", "call_remote")
func _request_sign_up(email: String, password: String, re_password: String) -> void:
	# Obtém o id do peer do jogador que solicitou a função
	var sender_id: int = multiplayer.get_remote_sender_id()
	var error_messages: Array[String] = []

	# Verifica se a versão do cliente está correta
	if Constants.version != Constants.version:
		error_messages.append("O seu cliente está desatualizado!")
		_on_sign_up_failed.rpc_id(sender_id, error_messages)
		return

	if password != re_password:
		error_messages.append("As senhas informadas não são iguais.")
		_on_sign_up_failed.rpc_id(sender_id, error_messages)
		return

	# Monta endpoint, headers e body da requisição
	var endpoint = Env.backend_endpoint + "auth/sign-up"
	var headers := {
		"Content-Type": "application/json",
		"Authorization": Env.backend_token
	}
	var body := {
		"email": email,
		"password": password,
		"rePassword": re_password,
	}

	# Faz a requisição para o backend
	var result := await Fetch.fetch_json(HTTPClient.METHOD_POST, endpoint, body, headers)
	var status_code = result[1]
	var response_data = result[2]

	# Se falhou, envia os erros pro cliente
	if status_code != 201:
		error_messages.append_array(Fetch.format_errors(response_data))
		# Chama a função de erro no cliente (sender_id)
		_on_sign_up_failed.rpc_id(sender_id, error_messages)
		return

	# Informa ao cliente que o cadastro foi bem-sucedido
	_on_sign_up_success.rpc_id(sender_id, response_data["message"])


@rpc("authority", "call_local")
func _on_sign_up_success(message: String) -> void:
	WindowManager.hide_interface("sign_up")
	WindowManager.show_interface("sign_in")

	ShowNotification.show([message])
	_reset_ui()


@rpc("authority", "call_local")
func _on_sign_up_failed(messages: Array[String]) -> void:
	ShowNotification.show(messages)
	_reset_ui()
