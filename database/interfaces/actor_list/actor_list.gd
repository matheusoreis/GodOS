class_name ActorListInterface
extends PanelContainer

@export_category("Nodes")
@export var slots_location: HBoxContainer

@export_category("Messages")
@export var _user_not_found_message: String = "Não foi possível te localizar no servidor!"
@export var _actor_delete_confirmation_message: String = "Deseja realmente apagar este personagem?"

@export_category("References")
@export var _actor_slot_scene: PackedScene

@export_category("Notification")
@export var _shared_canvas: CanvasLayer
@export var _notification_scene: PackedScene
@export var _confirmation_scene: PackedScene


func _clear_all_slots() -> void:
	for slot in slots_location.get_children():
		slot.queue_free()


func _create_slot() -> ActorSlotInterface:
	var slot: ActorSlotInterface = _actor_slot_scene.instantiate()
	slot.access_button_pressed.connect(_on_actor_accessed)
	slot.delete_button_pressed.connect(_show_delete_actor_confirmation)
	return slot


func add_actor_slot(actor_data: Dictionary) -> void:
	for slot in slots_location.get_children():
		if slot is ActorSlotInterface and slot._actor_data.is_empty():
			slot.set_actor_data(actor_data)
			return

	var slot := _create_slot()
	slot.set_actor_data(actor_data)
	slots_location.add_child(slot)


func remove_actor_slot_by_id(actor_id: int) -> void:
	for slot: ActorSlotInterface in slots_location.get_children():
		var actor_data: Dictionary = slot.get_actor_data()
		if slot and actor_data.get("id") == actor_id:
			slot.clear_actor_data()
			return


func update_slots(max_actors: int, actors: Array) -> void:
	_clear_all_slots()

	for actor_data in actors:
		var filled_slot := _create_slot()
		filled_slot.set_actor_data(actor_data)
		slots_location.add_child(filled_slot)

	for i in range(max_actors - actors.size()):
		var empty_slot := _create_slot()
		empty_slot.clear_actor_data()
		slots_location.add_child(empty_slot)


func _on_actor_accessed(actor_id: int) -> void:
	_access_actor_request.rpc_id(1, actor_id)


func _show_delete_actor_confirmation(actor_id: int) -> void:
	var confirmation_interface: ConfirmationInterface = _confirmation_scene.instantiate()
	confirmation_interface.set_message(_actor_delete_confirmation_message)
	confirmation_interface.on_confirm_pressed.connect(
		func(): _on_actor_deleted(actor_id)
	)

	_shared_canvas.add_child(confirmation_interface)


func _on_actor_deleted(actor_id: int) -> void:
	_delete_actor_request.rpc_id(1, actor_id)


@rpc("any_peer")
func _access_actor_request(actor_id: int) -> void:
	var peer_id = multiplayer.get_remote_sender_id()
	print("Acesso ao ator solicitado:", actor_id, ", peer_id:", peer_id)


@rpc("any_peer")
func _delete_actor_request(actor_id: int) -> void:
	var peer_id = multiplayer.get_remote_sender_id()

	var user: Dictionary = ServerGlobals.users.get(peer_id, null)
	if user == null:
		_respond_delete_with_error(peer_id, [_user_not_found_message])
		return

	var endpoint = ServerConstants.backend_endpoint + "actor/" + str(int(actor_id))
	var headers := {"Content-Type": "application/json"}
	var body := {
		"accountId": user["id"],
	}

	var result := await Fetch.fetch_json(HTTPClient.METHOD_DELETE, endpoint, body, headers)
	var status_code = result[1]
	var response_data = result[2]

	if status_code != 200:
		_respond_delete_with_error(peer_id, Fetch.format_errors(response_data))
		return

	_delete_actor_response.rpc_id(peer_id, [actor_id, []])


func _respond_delete_with_error(peer_id: int, message: Array) -> void:
	_delete_actor_response.rpc_id(peer_id, [-1, message])


@rpc("authority")
func _access_actor_response(data: Array) -> void:
	print("Acesso ao ator respondido:", data)


@rpc("authority")
func _delete_actor_response(data: Array) -> void:
	var success: int = data[0]
	var error: Array = data[1]

	if not error.is_empty():
		_show_notification(error)
		return

	remove_actor_slot_by_id(success)


func _show_notification(messages: Array) -> void:
	var notification_interface: NotificationInterface = _notification_scene.instantiate()
	notification_interface.set_message(messages)
	_shared_canvas.add_child(notification_interface)
