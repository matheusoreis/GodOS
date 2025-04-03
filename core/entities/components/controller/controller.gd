class_name Controller
extends Node2D


var _entity: Entity
var _last_direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	_entity = get_parent() as Entity
	if not _entity or _entity.name.to_int() != multiplayer.get_unique_id():
		return


func _input(event: InputEvent) -> void:
	if multiplayer.is_server():
		return


func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("walking_left", "walking_right", "walking_up", "walking_down")
	if direction != Vector2.ZERO:
		_last_direction = direction.normalized()

	_request_move_entity.rpc_id(1, direction)


@rpc("any_peer", "call_remote")
func _request_move_entity(direction: Vector2) -> void:
	if not _entity or not multiplayer.is_server():
		return

	# Aplica o movimento à entidade
	_move_entity(direction)


@rpc("authority", "call_local")
func _move_entity(direction: Vector2) -> void:
	if not _entity:
		return

	_entity.velocity = direction.normalized() * _entity._move_speed
