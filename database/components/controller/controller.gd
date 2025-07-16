class_name Controller
extends Node2D


var _last_direction: Vector2 = Vector2.RIGHT
var _entity: Actor


func _ready() -> void:
	_entity = get_parent() as Actor


func _physics_process(_delta: float) -> void:
	if not _should_process_input():
		return

	var input_direction = _get_movement_input()

	#Network.client.send(Packets.MOVE_ACTOR, [input_direction])


func _should_process_input() -> bool:
	if not _entity:
		return false

	if not _entity.name.to_int() == ClientGlobals.peer_id:
		return false

	return true


func _get_movement_input() -> Vector2:
	var direction = Input.get_vector("walking_left", "walking_right", "walking_up", "walking_down")

	if direction != Vector2.ZERO:
		_last_direction = direction.normalized()
	else:
		_last_direction = Vector2.ZERO

	return direction
