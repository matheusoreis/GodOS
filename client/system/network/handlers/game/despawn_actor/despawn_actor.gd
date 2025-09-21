extends Node


@export_group("References")
@export var map: Map


func _ready() -> void:
	Network.handlers = [
		[Packets.DESPAWN_ACTOR, _handle_despawn_actor],
	]


func _handle_despawn_actor(data: Dictionary) -> void:
	if not map:
		return

	var actor_id: int = int(data.get("actorId", -1))
	map.remove_entity_by_id(actor_id)
