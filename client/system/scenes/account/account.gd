extends Control

@export var actor_list_ui: ActorListUi
@export var create_actor_ui: CreateActorUi

func _ready() -> void:
	Network.registry = [
		[Packets.ACTOR_LIST, _handle_actor_list],
		[Packets.CREATE_ACTOR, _handle_create_actor],
		[Packets.DELETE_ACTOR, _handle_delete_actor],
		[Packets.SELECT_ACTOR, _handle_select_actor],
	]


func _handle_actor_list(data: Dictionary) -> void:
	if not data.get("success", false):
		Alert.show(data.get("message"))
		return

	var max_actors = data.get("maxActors")
	var actors = data.get("actors")
	if max_actors == null or actors == null:
		Alert.show("Dados da lista de personagens inválidos.")
		return

	actor_list_ui.update_slots(max_actors, actors)


func _handle_create_actor(data: Dictionary) -> void:
	create_actor_ui.set_form_interactive(true)

	if not data.get("success", false):
		Alert.show(data.get("message"))
		return
	
	var message = data.get("message")
	if message != null:
		Alert.show(message)

	Network.send_packet(Packets.ACTOR_LIST, {})

	create_actor_ui.hide()
	actor_list_ui.show()


func _handle_delete_actor(data: Dictionary) -> void:
	if not data.get("success", false):
		Alert.show(data.get("message"))
		return
	
	var message = data.get("message")
	if message != null:
		Alert.show(message)

	Network.send_packet(Packets.ACTOR_LIST, {})


func _handle_select_actor(data: Dictionary) -> void:
	if not data.get("success", false):
		Alert.show(data.get("message"))
		return
	
	var message = data.get("message")
	if message != null:
		Alert.show(message)

	get_tree().change_scene_to_file("res://system/scenes/game/game.tscn")
