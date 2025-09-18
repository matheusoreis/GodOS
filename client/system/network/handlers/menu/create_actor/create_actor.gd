extends Node


@export_group("References")
@export var actor_list_ui: ActorListUi
@export var create_actor_ui: CreateActorUi


func _ready() -> void:
	Network.handlers = [
		[Packets.CREATE_ACTOR, _handle_create_actor]
	]


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
