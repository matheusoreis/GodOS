extends Node


@export_group("References")
@export var game: Game


func _ready() -> void:
	Network.handlers = [
		[Packets.MOVE_ACTOR, _handle_move_actor],
	]

func _handle_move_actor(data: Dictionary) -> void:
	if not game.current_map:
		return

	var actor_id: int
	var entity: Entity

	# Correção de posição
	if not data.get("success", true):
		var last_valid = data.get("lastValid", null)
		if last_valid == null:
			Alert.show(data.get("message", "Movimento inválido."))
			return

		actor_id = int(last_valid.get("actorId", -1))
		entity = game.current_map.get_entity_by_id(actor_id)
		if entity:
			entity.apply_server_correction(last_valid)
		return

	# Movimento válido
	actor_id = int(data.get("actorId", -1))
	entity = game.current_map.get_entity_by_id(actor_id)
	if entity:
		var direction := Vector2(
			data.get("directionX", 0),
			data.get("directionY", 0)
		)
		entity.move_to(direction)
