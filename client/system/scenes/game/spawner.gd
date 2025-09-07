class_name ActorSpawner
extends Node

var _current_map: Map = null

var current_map: Map:
	set(value): _set_map(value)

func _set_map(map: Map) -> void:
	_current_map = map


func _spawn_actor(data: Dictionary, controllable: bool) -> void:
	if not _current_map:
		return
	
	var actor_scene: PackedScene = load("res://system/entity/entity.tscn")
	var actor: Entity = actor_scene.instantiate()

	actor.identifier = data.get("identifier", "unknown")
	actor.name = str(int(data.get("accountId", -1)))

	var sprite_node: Sprite2D = actor.sprite
	sprite_node.texture = load("res://assets/graphics/entities/%s" % data.get("sprite", "default.png"))

	var position: Vector2 = Vector2(
		data.get("positionX", 1),
		data.get("positionY", 1)
	)
	actor.position = position

	actor.current_direction = Vector2(
		data.get("directionX", 1),
		data.get("directionY", 1)
	)

	actor.controllable = controllable

	_current_map.add_entity(actor, position)


func handle_spawn_actor(data: Dictionary) -> void:
	_spawn_actor(data, true)


func handle_spawn_actors_to_me(actors: Array) -> void:
	for actor_data in actors:
		_spawn_actor(actor_data, false)


func handle_spawn_me_to_actors(actor: Dictionary) -> void:
	_spawn_actor(actor, false)
