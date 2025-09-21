class_name Entity
extends Node2D


@export_group("Settings")
@export var identifier: String
@export var map_position: Vector2i
@export var controllable: bool = false
@export var move_speed: float = 150.0

@export_group("Nodes")
@export var identifier_label: Label
@export var sprite: AnimatedSprite2D
@export var camera: Camera2D
@export var current_map: Map = null

var is_moving: bool = false
var current_direction: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var current_anim: String = ""


func _ready() -> void:
	_update_camera_state()


func _process(delta: float) -> void:
	if not is_moving:
		if current_direction != Vector2.ZERO:
			var animation = _get_stopped_anim(current_direction)
			_play_anim(animation)

			current_direction = Vector2.ZERO
		return

	_move_towards_target(delta)



func setup_from_data(data: Dictionary, is_controllable: bool, map: Map) -> void:
	identifier = data.get("identifier", "unknown")

	name = str(int(data.get("id", -1)))

	identifier_label.text = identifier

	map_position = Vector2i(
		data.get("positionX", 1),
		data.get("positionY", 1)
	)

	position = map.grid_to_world(map_position)

	current_direction = Vector2(
		data.get("directionX", 0),
		data.get("directionY", 1)
	)

	self.controllable = is_controllable
	self.current_map = map


func _move_towards_target(delta: float) -> void:
	position = position.move_toward(target_position, move_speed * delta)

	if position != target_position:
		return

	if current_map:
		map_position = current_map.world_to_grid(position)

	is_moving = false


func move_to(direction: Vector2) -> void:
	if is_moving or not current_map:
		return

	var movement_direction: Vector2i = Vector2i(direction)
	var new_world_position = current_map.move_entity(self, movement_direction)

	if new_world_position == position:
		return

	is_moving = true
	current_direction = direction
	target_position = new_world_position

	_play_anim(_get_walking_anim(current_direction))

	if controllable:
		Network.send_packet(Packets.MOVE_ACTOR, {
			"directionX": int(direction.x),
			"directionY": int(direction.y)
		})


func apply_server_correction(last_valid: Dictionary) -> void:
	map_position = Vector2i(
		int(last_valid.get("positionX", map_position.x)),
		int(last_valid.get("positionY", map_position.y))
	)

	if current_map:
		position = current_map.grid_to_world(map_position)

	current_direction = Vector2(
		last_valid.get("directionX", 0),
		last_valid.get("directionY", 1)
	)

	is_moving = false
	target_position = position
	_play_anim(_get_stopped_anim(current_direction))


func set_controllable(value: bool) -> void:
	controllable = value
	_update_camera_state()


func _update_camera_state() -> void:
	if not camera:
		return
	camera.enabled = controllable


func _get_walking_anim(dir: Vector2) -> String:
	match dir:
		Vector2.UP:
			return "walking_up"
		Vector2.DOWN:
			return "walking_down"
		Vector2.LEFT:
			return "walking_left"
		Vector2.RIGHT:
			return "walking_right"
		_:
			return "walking_down"


func _get_stopped_anim(dir: Vector2) -> String:
	match dir:
		Vector2.UP:
			return "stopped_up"
		Vector2.DOWN:
			return "stopped_down"
		Vector2.LEFT:
			return "stopped_left"
		Vector2.RIGHT:
			return "stopped_right"
		_:
			return "stopped_down"


func _play_anim(anim: String) -> void:
	if anim == "" or current_anim == anim:
		return

	current_anim = anim
	sprite.play(anim)
