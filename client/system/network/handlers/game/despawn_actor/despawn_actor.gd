extends Node


@export_group("References")
@export var game: Game


func _ready() -> void:
	Network.handlers = [
		[Packets.DISCONNECT_ACTOR, _handle_disconnect_actor],
	]


func _handle_disconnect_actor(data: Dictionary) -> void:
	if not game.current_map:
		return

	var actor_id: int = int(data.get("actorId", -1))
	game.current_map.remove_entity_by_id(actor_id)
