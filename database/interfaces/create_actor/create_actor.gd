class_name CreateActorUI
extends Interface


@export_group("Objects")
@onready var _client: Client = $"../../Network/Client"
@onready var _close_button: Button = $content/top_bar/margin/close
@onready var _name_line: LineEdit = $content/margin/content/inputs/name
@onready var _confirm_button: Button = $content/margin/content/buttons/confirm

@export_group("Variables")
@export var min_name_length: int = 4
@export var max_name_length: int = 14

var _name_regex: String = "^[a-z0-9]+(?: [a-z0-9]+)?$"


func _ready() -> void:
	super()

	# Garante que o cliente está configurado
	if not _client:
		return

	# Conecta o sinal de "pressionado" do botão de confirmar
	_confirm_button.pressed.connect(
		func():
			var name_text = _name_line.text

			if name_text.is_empty():
				print("Por favor, preencha todos os campos.")
				return

			_confirm_button.disabled = true
			_close_button.disabled = true

			# Envia a requisição de sign in para o servidor
			_request_create_actor.rpc_id(1, name_text)
	)

	# Conecta o sinal de "pressionado" do botão de cadastrar
	_close_button.pressed.connect(
		func():
			WindowManager.hide_interface("create_actor")
			WindowManager.show_interface("sign_in")
	)

	# Valida o e-mail enquanto o usuário digita
	_name_line.text_changed.connect(
		func(new_text: String):
			var is_valid = RegEx.create_from_string(_name_regex).search(new_text) != null
			_name_line.add_theme_color_override(
				"font_color", Color.RED if not is_valid else Color.WHITE
			)
	)

	# Ativa os botões quando o cliente conectar ao servidor
	_client.connected_to_server.connect(
		func():
			_confirm_button.disabled = false
	)


func _reset_ui() -> void:
	_close_button.disabled = false
	_confirm_button.disabled = false

	_name_line.clear()


@rpc("any_peer", "call_remote")
func _request_create_actor(name: String) -> void:
	print("Requisição")
	# Obtém o id do peer do jogador que solicitou a função
	var sender_id: int = multiplayer.get_remote_sender_id()
	var error_messages: Array[String] = []
#
	# Verifica se a versão do cliente está correta
	if Constants.version != Constants.version:
		error_messages.append("O seu cliente está desatualizado!")
		_on_create_actor_failed.rpc_id(sender_id, error_messages)
		return

	if not Globals.users.has(sender_id):
		return

	var user: Dictionary = Globals.users[sender_id]

	# Monta endpoint, headers e body da requisição
	var endpoint = Env.backend_endpoint + "actor"
	var headers := {
		"Content-Type": "application/json",
		"Authorization": Env.backend_token
	}
	var body := {
		"userId": user["id"],
		"name": name,
	}

	var result := await Fetch.fetch_json(HTTPClient.METHOD_POST, endpoint, body, headers)
	var status_code = result[1]
	var response_data = result[2]

	## Se falhou, envia os erros pro cliente
	#if status_code != 201:
		#error_messages.append_array(Fetch.format_errors(response_data))
		## Informa ao cliente que a requisição foi mal-sucedida
		#_on_sign_up_failed.rpc_id(sender_id, error_messages)
		#return
#
	## Verifica se o usuário já está logado com esse sender_id
	#if Globals.users.has(sender_id):
		#error_messages.append("Você já está autenticado no servidor!")
		## Informa ao cliente que o sign in foi mal-sucedido
		#_on_sign_up_failed.rpc_id(sender_id, error_messages)
		#return
#
	## Verifica se outro usuário com mesmo ID já está conectado
	#for existing_user in Globals.users.values():
		#if existing_user["id"] == response_data["id"]:
			#error_messages.append("Essa conta já está conectada ao servidor por outro dispositivo!")
			## Informa ao cliente que o sign in foi mal-sucedido
			#_on_sign_up_failed.rpc_id(sender_id, error_messages)
			#return
#
	## Cria e armazena o dicionário do usuário
	#var user: Dictionary = {
		#"id": response_data["id"],
		#"email": response_data["email"],
		#"max_actors": response_data["max_actors"],
		#"last_login": response_data["last_login"],
		#"created_at": response_data["created_at"],
		#"updated_at": response_data["updated_at"],
	#}
	#Globals.users[sender_id] = user

	# Solicita a lista de personagens
	#var actor_list_ui: ActorsListUi = WindowManager.get_interface("actor_list")
	#actor_list_ui.request_actors(sender_id)

	# Informa ao cliente que o sign in foi bem-sucedido
	#_on_sign_in_success.rpc_id(sender_id, "Sucesso ao acessar o jogo!")


@rpc("authority", "call_local")
func _on_create_actor_success(message: String) -> void:
	WindowManager.hide_interface("sign_in")
	WindowManager.show_interface("actor_list")

	ShowNotification.show([message])
	_reset_ui()


@rpc("authority", "call_local")
func _on_create_actor_failed(messages: Array[String]) -> void:
	ShowNotification.show(messages)
	_reset_ui()
