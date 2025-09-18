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

	var max_actors = data.get("maxActors", 1)
	if max_actors == null:
		Alert.show("Quantidade máxima de personagens não informada!")

	var actors = data.get("actors", null)
	if actors == null:
		Alert.show("Dados dos personagens não foi informado!")
		return

	actor_list_ui.update_slots(max_actors, actors)
