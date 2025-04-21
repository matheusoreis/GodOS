class_name Controller
extends Node2D

var _last_direction: Vector2 = Vector2.RIGHT
var _entity: Entity


func _ready() -> void:
	_entity = get_parent() as Entity


func _physics_process(_delta: float) -> void:
	if not _should_process_input():
		return

	var input_direction = _get_movement_input()
	_request_move.rpc_id(1, input_direction)


func _should_process_input() -> bool:
	return _entity and _entity.name.to_int() == multiplayer.get_unique_id()


func _get_movement_input() -> Vector2:
	var direction = Input.get_vector("walking_left", "walking_right", "walking_up", "walking_down")

	if Globals.is_typing:
		return Vector2.ZERO

	if direction != Vector2.ZERO:
		_last_direction = direction.normalized()
	else:
		_last_direction = Vector2.ZERO

	return direction


@rpc("any_peer", "call_remote")
func _request_move(direction: Vector2) -> void:
	var map: Map = get_tree().root.get_node_or_null('Main/Game/Map')
	if not map:
		return

	if not _entity:
		return

	var sender_id = multiplayer.get_remote_sender_id()
	var sender_actor: Actor = map.actors[sender_id]

	sender_actor.move(direction, sender_actor.agility.get_value())
