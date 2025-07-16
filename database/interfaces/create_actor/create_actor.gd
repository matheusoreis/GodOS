class_name CreateActorInterface
extends PanelContainer


@export var name_input: LineEdit
@export var create_button: Button
@export var back_button: Button


func _ready() -> void:
	create_button.pressed.connect(_on_create_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)


func _on_create_button_pressed() -> void:
	var name: String = name_input.text

	if name.length() <= 3:
		Notification.show(["O nome precisa ter ao menos 4 caracteres."])
		return

	#Network.client.send(Packets.CREATE_ACTOR, [name])


func _on_back_button_pressed() -> void:
	self.hide()

	var create_actor_interface: SignUpInterface = get_tree().root.get_node("Game/MenuCanvas/CreateActor")
	create_actor_interface.hide()


@rpc("any_peer")
func _create_actor_request(data: Dictionary) -> void:
	# Obtem o ID do peer que enviou a requisição
	var peer_id = multiplayer.get_remote_sender_id()

	var user: Dictionary = ServerGlobals.users.get(peer_id, null)
	if user == null:
		_create_actor_response.rpc_id(peer_id, [-1, ["Não foi possível te localizar no servidor!"]])
		return
	
	# Obtem o nome do personagem
	var name: String = data.name


@rpc("authority")
func _create_actor_response(data: Dictionary) -> void:
	# Obtem os dados de sucesso da resposta
	var success: Dictionary = data[0]
	# Obtem os erros da resposta
	var error: Array = data[1]