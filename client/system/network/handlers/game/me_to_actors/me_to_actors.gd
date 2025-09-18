extends Node


@export_group("References")
@export var game: Game


func _ready() -> void:
	Network.handlers = [
		[Packets.ME_TO_ACTORS, _handle_me_to_actors],
	]


func _handle_me_to_actors(data: Dictionary) -> void:
	if data == null or not game.current_map:
		return

	game.current_map.spawn_actor(data, false)
