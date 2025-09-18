extends Node


@export_group("References")
@export var actor_list_ui: ActorListUi


func _ready() -> void:
	Network.handlers = [
		[Packets.ACTOR_LIST, _handle_actor_list]
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
