class_name CreateActorInterface
extends PanelContainer

@export_category("Nodes")
@export var _name_input: LineEdit
@export var _back_button: Button
@export var _create_button: Button

@export_category("Messages")
@export var _invalid_name_message: String = "O nome precisa ter ao menos 4 caracteres."
@export var _user_not_found_message: String = "Não foi possível te localizar no servidor!"

@export_category("References")
@export var _actor_list_interface: ActorListInterface


func _ready() -> void:
	_create_button.pressed.connect(_on_create_button_pressed)
	_back_button.pressed.connect(_on_back_button_pressed)


func _on_create_button_pressed() -> void:
	var actor_name: String = _name_input.text

	if actor_name.length() <= 3:
		Notification.show([_invalid_name_message])
		return

	_name_input.editable = false
	_create_button.disabled = true
	_back_button.disabled = true

	_create_actor_request.rpc_id(1, {"name": actor_name})


func _on_back_button_pressed() -> void:
	_actor_list_interface.show()
	hide()


@rpc("any_peer")
func _create_actor_request(data: Dictionary) -> void:
	var peer_id = multiplayer.get_remote_sender_id()

	var user: Dictionary = ServerGlobals.users.get(peer_id, null)
	if user == null:
		_respond_with_error(peer_id, [_user_not_found_message])
		return

	var account_id: int = user["id"]

	var actor_name: String = data.name
	if actor_name.length() < 3:
		_respond_with_error(peer_id, [_invalid_name_message])
		return

	var endpoint = ServerConstants.backend_endpoint + "actor"
	var headers := {"Content-Type": "application/json"}
	var body := {
		"accountId": account_id,
		"name": actor_name,
		"mapId": 1,
		"positionX": 32,
		"positionY": 32
	}

	var result := await Fetch.fetch_json(HTTPClient.METHOD_POST, endpoint, body, headers)
	var status_code = result[1]
	var response_data = result[2]

	if status_code != 201:
		_respond_with_error(peer_id, Fetch.format_errors(response_data))
		return

	_create_actor_response.rpc_id(peer_id, [response_data, []])


func _respond_with_error(peer_id: int, message: Array) -> void:
	_create_actor_response.rpc_id(peer_id, [{}, message])


@rpc("authority")
func _create_actor_response(data: Array) -> void:
	var success: Dictionary = data[0]
	var error: Array = data[1]

	if not error.is_empty():
		reset_form()
		Notification.show(error)
		return

	reset_form()
	hide()

	_actor_list_interface.show()
	_actor_list_interface.add_actor_slot(success)


func reset_form() -> void:
	_name_input.clear()

	_name_input.editable = true

	_create_button.disabled = false
	_back_button.disabled = false
