class_name CreateActorUI
extends Interface


@export_group("Objects")
@onready var _map: Map = $"../../Game/Map"
@onready var _close_button: Button = $content/top_bar/margin/close
@onready var _name_line: LineEdit = $content/margin/content/inputs/name
@onready var _confirm_button: Button = $content/margin/content/buttons/confirm

@export_group("Variables")
@export var min_name_length: int = 4
@export var max_name_length: int = 14

var _name_regex: String = "^[a-z0-9]+(?: [a-z0-9]+)?$"


func _ready() -> void:
	super()

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


func _reset_ui() -> void:
	_close_button.disabled = false
	_confirm_button.disabled = false

	_name_line.clear()


@rpc("any_peer", "call_remote")
func _request_create_actor(name: String) -> void:
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

	if status_code != 201:
		error_messages.append(response_data["message"])
		_on_create_actor_failed.rpc_id(sender_id, error_messages)
		return

	Globals.users[sender_id]["actor"] = response_data
	_on_create_actor_success.rpc_id(sender_id, response_data)

	_map._actor_spawner.spawn(response_data)


@rpc("authority", "call_local")
func _on_create_actor_success(actor: Dictionary) -> void:
	$"..".hide()


@rpc("authority", "call_local")
func _on_create_actor_failed(messages: Array[String]) -> void:
	ShowNotification.show(messages)
	_reset_ui()
