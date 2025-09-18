class_name Game
extends Node2D


var current_map: Map


func _ready() -> void:
	Network.handlers = [
		[Packets.MAP_DATA, _handle_map_data],
		[Packets.ME_TO_ACTORS, _handle_me_to_actors],
		[Packets.MOVE_ACTOR, _handle_move_actor],
		[Packets.DISCONNECT, _handle_disconnect_actor],
	]


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


func _spawn_actor(data: Dictionary, controllable: bool) -> void:
	if not current_map:
		return

	var actor_scene: PackedScene = load("res://system/entity/entity.tscn")
	var actor: Entity = actor_scene.instantiate()

	actor.setup_from_data(data, controllable, current_map)
	current_map.add_entity(actor, actor.map_position)


func _spawn_player_actor(data: Dictionary) -> void:
	_spawn_actor(data, true)


func _spawn_other_actor(data: Dictionary) -> void:
	_spawn_actor(data, false)


func _spawn_other_actors(actors: Array) -> void:
	for actor_data in actors:
		_spawn_actor(actor_data, false)


func _handle_map_data(data: Dictionary) -> void:
	if not data.get("success", false):
		Alert.show(data.get("message"))
		return

	var map = data.get("map")

	var actor = data.get("actor")
	Globals.actor = actor

	var actors = data.get("actors", [])
	#var npcs = data.get("npcs", [])
	#var items = data.get("items", [])

	if map == null or actor == null:
		Alert.show("Dados do mapa ou do personagem não foram recebidos.")
		return

	_load_map(map["file"], map["identifier"])

	_spawn_player_actor(actor)

	for other_actor in actors:
		if other_actor["id"] != actor["id"]:
			_spawn_other_actor(other_actor)


func _handle_me_to_actors(data: Dictionary) -> void:
	_spawn_other_actor(data)


func _handle_move_actor(data: Dictionary) -> void:
	if not current_map:
		return

	var actor_id: int
	var entity: Entity

	# Corrigindo a posição
	if not data.get("success", true):
		var last_valid = data.get("lastValid", null)
		if last_valid == null:
			Alert.show(data.get("message", "Movimento inválido."))
			return

		actor_id = int(last_valid.get("actorId", -1))
		entity = current_map.get_entity_by_id(actor_id)
		if entity:
			entity.apply_server_correction(last_valid)
		return

	# Movimento válido
	actor_id = int(data.get("actorId", -1))
	entity = current_map.get_entity_by_id(actor_id)
	if entity:
		var direction := Vector2(
			data.get("directionX", 0),
			data.get("directionY", 0)
		)
		entity.move_to(direction)


func _handle_disconnect_actor(data: Dictionary) -> void:
	if not current_map:
		return

	var actor_id: int = int(data.get("actorId", -1))
	current_map.remove_entity_by_id(actor_id)
#
