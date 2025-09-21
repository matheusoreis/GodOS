extends Node


@export_group("References")
@export var map: Map


func _ready() -> void:
	Network.handlers = [
		[Packets.ME_TO_ACTORS, _handle_me_to_actors],
	]


func _handle_me_to_actors(data: Dictionary) -> void:
	if data == null or not map:
		return

	map.spawn_actor(data, false)
