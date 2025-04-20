class_name Controller
extends Node2D

var _last_direction: Vector2 = Vector2.RIGHT
var _entity: Entity


func _ready() -> void:
	_entity = get_parent() as Entity


func _input(event: InputEvent) -> void:
	if multiplayer.is_server():
		return


func _physics_process(delta: float) -> void:
	if not _entity or _entity.name.to_int() != multiplayer.get_unique_id():
		return

	var direction: Vector2 = Input.get_vector("walking_left", "walking_right", "walking_up", "walking_down")
	if direction != Vector2.ZERO:
		_last_direction = direction.normalized()

	_request_move_actor.rpc_id(1, direction)


@rpc("any_peer", "call_remote")
func _request_move_actor(direction: Vector2) -> void:
	var map: Map = get_tree().root.get_node_or_null('Main/Game/Map')
	if not map:
		return

	if not _entity:
		return

	var sender_id = multiplayer.get_remote_sender_id()
	var sender_actor: Actor = map.actors[sender_id]

	sender_actor.move(direction, sender_actor.agility.get_value())
