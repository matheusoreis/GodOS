class_name SignUpInterface
extends PanelContainer


@export var _email_input: LineEdit
@export var _password_input: LineEdit
@export var _re_password_input: LineEdit
@export var _back_button: Button
@export var _sign_up_button: Button


func _ready() -> void:
	self._back_button.pressed.connect(_on_back_button_pressed)
	self._sign_up_button.pressed.connect(_on_sign_up_button_pressed)


func _on_sign_up_button_pressed() -> void:
	# Obtem o text dos campos de email, senha e confirmação de senha
	var email: String = self._email_input.text
	var password: String = self._password_input.text
	var re_password: String = self._re_password_input.text

	# Verifica se o email informado é válido
	if email.length() <= 6:
		Notification.show(["O email precisa ter ao menos 6 caracteres."])
		return

	# Verifica se a senha informada é válida
	if password.length() < 3:
		Notification.show(["A senha precisa ter ao menos 3 caracteres."])
		return

	# Verifica se a confirmação de senha é válida
	if password != re_password:
		Notification.show(["A senha informada não corresponde à confirmação."])
		return

	# Desativa os botões para evitar múltiplos cliques
	self._back_button.disabled = true
	self._sign_up_button.disabled = true

	# Envia a requisição para o servidor
	self._sign_up_request.rpc_id(1, {
		"email": email,
		"password": password,
		"version": ClientConstants.version
	})


func _on_back_button_pressed() -> void:
	self.hide()

	var sign_in_interface: SignInInterface = get_tree().root.get_node("Game/MenuCanvas/SignIn")
	sign_in_interface.show()


func reset_form() -> void:
	self._email_input.text = ""
	self._password_input.text = ""
	self._re_password_input.text = ""

	self._back_button.disabled = false
	self._sign_up_button.disabled = false


@rpc("any_peer")
func _sign_up_request(data: Dictionary) -> void:
	# Obtem o ID do peer que enviou a requisição
	var peer_id = multiplayer.get_remote_sender_id()

	# Obtem o email, password e versão do cliente da requisição
	var email: String = data.email
	var password: String = data.password
	var version: Vector3 = data.version

	# Verifica se a versão do cliente é compatível com a versão do servidor
	if version != ServerConstants.version:
		self._sign_in_response.rpc_id(peer_id, [ {}, ["Versão do cliente incompatível."]])
		return

	# Verifica se o email informado é válido, enviando uma resposta de erro se não for
	if email.length() <= 6:
		self._sign_in_response.rpc_id(peer_id, [ {}, ["O email precisa ter ao menos 6 caracteres."]])
		return

	# Verifica se a senha informada é válida, enviando uma resposta de erro se não for
	if password.length() < 3:
		self._sign_in_response.rpc_id(peer_id, [ {}, ["A senha precisa ter ao menos 3 caracteres."]])
		return

	# Constrói a requisição para o servidor
	var endpoint = ServerConstants.backend_endpoint + "account/sign-up"
	var headers := {"Content-Type": "application/json"}
	var body := {
		"email": email,
		"password": password,
		"rePassword": password,
	}

	# Envia a requisição para a api e aguarda a resposta
	var result := await Fetch.fetch_json(HTTPClient.METHOD_POST, endpoint, body, headers)
	var status_code = result[1]
	var response_data = result[2]

	# Se a requisição falhou, envia uma resposta de erro ao cliente
	if status_code != 201:
		self._sign_in_response.rpc_id(peer_id, [ {}, Fetch.format_errors(response_data)])
		return

	# Responde ao cliente com sucesso
	self._sign_up_response.rpc_id(peer_id, ["Sucesso ao se cadastrar no jogo!", []])


@rpc("authority")
func _sign_up_response(data: Array) -> void:
	# Obtem os dados de sucesso da resposta
	var success: String = data[0]
	# Obtem os erros da resposta
	var error: Array = data[1]

	# Verifica se houve algum erro na resposta
	if not error.is_empty():
		Notification.show(error)
		return

	# Reseta o formulário de autenticação e fecha a interface
	self.reset_form()
	self.hide()

	Notification.show([success])

	# Exibe a interface de SignIn
	var sign_in_interface: SignInInterface = get_tree().root.get_node("Game/MenuCanvas/SignIn")
	sign_in_interface.show()
