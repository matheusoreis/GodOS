class_name ActorListInterface
extends PanelContainer


@export var slots_location: HBoxContainer


func update_slot(max_actors: int, actors: Array) -> void:
	if typeof(actors) != TYPE_ARRAY:
		return

	var empty_slot: PackedScene = preload("res://database/interfaces/actor_list/empty_slot.tscn")
	var actor_slot: PackedScene = preload("res://database/interfaces/actor_list/actor_slot.tscn")

	for child in slots_location.get_children():
		child.queue_free()

	for i in range(actors.size()):
		var data: Dictionary = actors[i]

		var slot: ActorSlotInterface = actor_slot.instantiate()
		slot.name = str(int(data["id"]))
		slot.update_data(data)

		slot.access_button_pressed.connect(_on_actor_accessed)
		slot.delete_button_pressed.connect(_on_actor_deleted)

		slots_location.add_child(slot)

	var remaining_slots = max_actors - actors.size()
	for i in range(remaining_slots):
		var slot: EmptyActorSlotInterface = empty_slot.instantiate()
		slots_location.add_child(slot)


func _on_actor_accessed(actor_id: int) -> void:
	_access_actor_request.rpc(actor_id)


func _on_actor_deleted(actor_id: int) -> void:
	_delete_actor_request.rpc(actor_id)


@rpc("any_peer")
func _access_actor_request(actor_id: int) -> void:
	# Obtem o ID do peer que enviou a requisição
	var peer_id = multiplayer.get_remote_sender_id()

	# TODO: Implementar lógica de acesso ao ator
	print("Acesso ao ator solicitado:", actor_id, ", peer_id:", peer_id)


@rpc("any_peer")
func _delete_actor_request(actor_id: int) -> void:
	# Obtem o ID do peer que enviou a requisição
	var peer_id = multiplayer.get_remote_sender_id()

	var user: Dictionary = ServerGlobals.users.get(peer_id, null)
	if user == null:
		_delete_actor_response.rpc_id(peer_id, [-1, ["Não foi possível te localizar no servidor!"]])
		return

	# Constrói a requisição para o servidor
	var endpoint = ServerConstants.backend_endpoint + "actor"
	var headers := {"Content-Type": "application/json"}
	var body := {
		"id": actor_id,
		"accountId": user["id"],
	}

	# Envia a requisição para o servidor e aguarda a resposta
	var result := await Fetch.fetch_json(HTTPClient.METHOD_DELETE, endpoint, body, headers)
	var status_code = result[1]
	var response_data = result[2]

	# Se a requisição falhou, envia uma resposta de erro ao cliente
	if status_code != 200:
		_delete_actor_response.rpc_id(peer_id, [-1, Fetch.format_errors(response_data)])
		return
	
	_delete_actor_response.rpc_id(peer_id, [actor_id, []])


@rpc("authority")
func _access_actor_response(data: Array) -> void:
	print("Acesso ao ator respondido:", data)


@rpc("authority")
func _delete_actor_response(data: Array) -> void:
	# Obtem os dados de sucesso da resposta
	var success: int = data[0]
	# Obtem os erros da resposta
	var error: Array = data[1]

	# Verifica se houve algum erro na autenticação e exibe uma notificação
	if not error.is_empty():
		Notification.show(error)
		return

	# Procura o slot pelo nome e remove
	for child in slots_location.get_children():
			if child.name == str(success):
				child.queue_free()
				break
		
	# Adiciona um novo slot vazio
	var empty_slot: PackedScene = preload("res://database/interfaces/actor_list/empty_slot.tscn")
	var slot: EmptyActorSlotInterface = empty_slot.instantiate()
	slots_location.add_child(slot)