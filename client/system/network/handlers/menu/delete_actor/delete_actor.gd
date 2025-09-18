extends Node


@export_group("References")
@export var actor_list_ui: ActorListUi
@export var create_actor_ui: CreateActorUi


func _ready() -> void:
	Network.handlers = [
		[Packets.DELETE_ACTOR, _handle_delete_actor]
	]


func _handle_delete_actor(data: Dictionary) -> void:
	if not data.get("success", false):
		Alert.show(data.get("message"))
		return

	var message = data.get("message", false)
	if message != null:
		Alert.show(message)

	Network.send_packet(Packets.ACTOR_LIST, {})
