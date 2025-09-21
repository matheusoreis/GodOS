extends Node


var current_map: Map


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

	_load_map(map["file"], map["identifier"])

	current_map.spawn_actor(actor, true)

	for other_actor in actors:
		if other_actor["id"] != actor["id"]:
			current_map.spawn_actor(other_actor, false)


func _load_map(map_file: String, identifier: String) -> void:
	if current_map:
		current_map.queue_free()
		current_map = null

	var packed_map: PackedScene = load("res://database/maps/%s.tscn" % map_file)
	if not packed_map:
		push_error("Falha ao carregar o mapa %s" % map_file)
		return

	current_map = packed_map.instantiate()
	current_map.identifier = identifier

	add_child(current_map)
