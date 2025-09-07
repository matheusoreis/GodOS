class_name Game
extends Node2D


@export var actor_spawner: ActorSpawner

var current_map: Map = null


func _ready() -> void:
	load_map(Globals.map["file"], Globals.map["identifier"])
	
	actor_spawner.handle_spawn_actor(Globals.actor)
	
	Network.registry = [
		[Packets.ACTORS_TO_ME, actor_spawner.handle_spawn_actors_to_me],
		[Packets.ME_TO_ACTORS, actor_spawner.handle_spawn_me_to_actors],
		[Packets.MOVE_ACTOR, handle_move_actor],
	]


func load_map(map_file: String, identifier: String) -> void:
	if current_map:
		current_map.queue_free()
		current_map = null

	var loaded_map: PackedScene = load("res://database/maps/%s.tscn" % map_file)
	if not loaded_map:
		return

	current_map = loaded_map.instantiate()
	current_map.identifier = identifier
	add_child(current_map)

	actor_spawner.current_map = current_map


func handle_move_actor(data: Dictionary) -> void:
	if not current_map:
		return

	var actor_id: String = str(int(data.get("actorId", -1)))
	var direction := Vector2(
		data.get("directionX", 0),
		data.get("directionY", 0)
	)

	var entity: Entity = current_map.spawn_location.get_node_or_null(actor_id)
	if entity:
		entity.move_to(direction)
