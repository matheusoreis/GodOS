class_name ActorsListUi extends Interface


@export var slots_location: HBoxContainer


func request_actors(sender_id: int) -> void:
	var error_messages: Array = []

	var user: Dictionary = Globals.users[sender_id]
	if not user.has("id"):
		return

	var user_id = user["id"]
	var max_actor_slots = user["max_actors"]

	var endpoint = Env.backend_endpoint + "actor?userId=" + str(user_id)
	var headers = {
		"Content-Type": "application/json",
		"Authorization": Env.backend_token
	}

	var result := await Fetch.fetch_json(HTTPClient.METHOD_GET, endpoint, {}, headers)
	var status_code = result[1]
	var response_data = result[2]

	if status_code != 200:
		error_messages.append_array(Fetch.format_errors(response_data))
		_on_actor_list_failed.rpc_id(sender_id, error_messages)
		multiplayer.multiplayer_peer.disconnect_peer(sender_id)
		return

	var actors: Array[Dictionary] = []
	for data in response_data:
		actors.append({
			"id": data["id"],
			"name": data["name"],
			"direction": Vector2(
				data["direction_x"],
				data["direction_y"]
			),
			"world": data["world"],
			"position": Vector2(
				data["position_x"],
				data["position_y"]
			)
		})

	_update_actor_panels.rpc_id(sender_id, user["max_actors"], actors)


@rpc("authority", "call_local")
func _on_actor_list_failed(messages: Array[String]) -> void:
	ShowNotification.show(messages)


@rpc("authority", "call_local")
func _update_actor_panels(max_actors: int, actors: Array[Dictionary]) -> void:
	var select_slot_scene := load(
		"res://interface/scenes/actor_list/select_slot/actor_list_select_slot.tscn"
	) as PackedScene

	var create_slot_scene := load(
		"res://interface/scenes/actor_list/create_slot/actor_list_create_slot.tscn"
	) as PackedScene

	for child in slots_location.get_children() as Array[Node]:
		child.queue_free()

	for i in range(actors.size()):
		var data: Dictionary = actors[i]
		var slot := select_slot_scene.instantiate() as ActorListSelectSlotUi

		slot.name = str(data["id"])
		slot.actor_id = data["id"]
		slot.name_label.text = data["name"]

		slots_location.add_child(slot)

	var remaining_slots = max_actors - actors.size()
	for i in range(remaining_slots):
		var create_slot := create_slot_scene.instantiate() as ActorListCreateSlotUi
		slots_location.add_child(create_slot)


func _on_close_pressed() -> void:
	WindowManager.hide_interface("actors_list")
	WindowManager.show_interface("sign_in")
