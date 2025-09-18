extends Node


@export_group("References")
@export var game: Game


func _ready() -> void:
	Network.handlers = [
		[Packets.MAP_DATA, _handle_map_data],
	]


func _handle_map_data(data: Dictionary) -> void:
	if not data.get("success", false):
		Alert.show(data.get("message"))
		return

	var map = data.get("map")
	var actor = data.get("actor")
	Globals.actor = actor
	var actors = data.get("actors", [])

	if map == null or actor == null:
		Alert.show("Dados do mapa ou do personagem não foram recebidos.")
		return

	game.load_map(map["file"], map["identifier"])

	game.current_map.spawn_actor(actor, true)

	for other_actor in actors:
		if other_actor["id"] != actor["id"]:
			game.current_map.spawn_actor(other_actor, false)
