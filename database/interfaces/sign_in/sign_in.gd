class_name SignInInterface
extends PanelContainer


@export var _email_input: LineEdit
@export var _password_input: LineEdit

@export var _sign_in_button: Button
@export var _sign_up_button: Button


func _ready() -> void:
	# Conecta o sinal do botão de sign_in
	self._sign_in_button.pressed.connect(_on_sign_in_button_pressed)
	# Conecta o sinal do botão de sign_up
	self._sign_up_button.pressed.connect(_on_sign_up_button_pressed)


func _on_sign_in_button_pressed() -> void:
	# Obtem o text dos campos de email e senha
	var email: String = self._email_input.text
	var password: String = self._password_input.text

	# Verifica se o email informado é válido
	if email.length() <= 6:
		Notification.show(["O email precisa ter ao menos 6 caracteres."])
		return

	# Verifica se a senha informada é válida
	if password.length() < 3:
		Notification.show(["A senha precisa ter ao menos 3 caracteres."])
		return

	# Desativa os botões para evitar múltiplos cliques
	self._sign_in_button.disabled = true
	self._sign_up_button.disabled = true

	# Envia a requisição para o servidor
	self._sign_in_request.rpc_id(1, {
		"email": email,
		"password": password,
		"version": ClientConstants.version
	})


func _on_sign_up_button_pressed() -> void:
	self.hide()

	# Exibe a interface de SignUp
	var sign_up_interface: SignUpInterface = get_tree().root.get_node("Game/MenuCanvas/SignUp")
	sign_up_interface.show()


func reset_form() -> void:
	# Reseta os campos de email e senha
	self._email_input.clear()
	self._password_input.clear()

	# Reativa os botões de sign in e sign up
	self._sign_in_button.disabled = false
	self._sign_up_button.disabled = false


@rpc("any_peer")
func _sign_in_request(data: Dictionary) -> void:
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
	var endpoint = ServerConstants.backend_endpoint + "account/sign-in"
	var headers := {"Content-Type": "application/json"}
	var body := {
		"email": email,
		"password": password
	}

	# Envia a requisição para a api e aguarda a resposta
	var result := await Fetch.fetch_json(HTTPClient.METHOD_POST, endpoint, body, headers)
	var status_code = result[1]
	var response_data = result[2]

	# Se a requisição falhou, envia uma resposta de erro ao cliente
	if status_code != 201:
		self._sign_in_response.rpc_id(peer_id, [ {}, Fetch.format_errors(response_data)])
		return

	# Se o usuário já está autenticado, envia uma resposta de erro ao cliente
	if ServerGlobals.users.has(peer_id):
		self._sign_in_response.rpc_id(peer_id, [ {}, ["Você já está autenticado no servidor!"]])
		return

	# Se a autenticação foi bem-sucedida, armazena os dados do usuário
	ServerGlobals.users[peer_id] = response_data

	# Responde ao cliente com os dados do usuário autenticado
	self._sign_in_response.rpc_id(peer_id, [response_data, []])


@rpc("authority")
func _sign_in_response(data: Array) -> void:
	# Obtem os dados de sucesso da resposta
	var success: Dictionary = data[0]
	# Obtem os erros da resposta
	var error: Array = data[1]

	# Verifica se houve algum erro na resposta
	if not error.is_empty():
		Notification.show(error)
		self.reset_form()
		return

	# Armazena os dados do usuário autenticado na memória
	ClientGlobals.user_data = success

	# Reseta o formulário de autenticação e fecha a interface
	self.reset_form()
	self.hide()

	# Exibe a interface de ActorList e atualiza a lista de actors
	var actor_list_interface: ActorListInterface = get_tree().root.get_node("Game/MenuCanvas/ActorList")
	actor_list_interface.show()
	actor_list_interface.update_slot(success["maxActors"], success["actors"])
