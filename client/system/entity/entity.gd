class_name Entity
extends Node2D


signal movement_finished(entity: Entity)


@export_group("Settings")
@export var identifier: String
@export var map_position: Vector2i
@export var controllable: bool = false
@export var move_speed: float = 150.0

@export_group("Nodes")
@export var sprite: Sprite2D
@export var camera: Camera2D
@export var current_map: Map = null

var is_moving: bool = false
var current_direction: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	_update_camera_state()


func _process(delta: float) -> void:
	if is_moving:
		_move_towards_target(delta)


func setup_from_data(data: Dictionary, is_controllable: bool, map: Map) -> void:
	identifier = data.get("identifier", "unknown")
	name = str(int(data.get("id", -1)))

	var sprite_name = data.get("sprite", "ghost.png")
	sprite.texture = load("res://assets/graphics/entities/%s" % sprite_name)

	map_position = Vector2i(
		data.get("positionX", 1),
		data.get("positionY", 1)
	)

	position = map.grid_to_world(map_position)

	current_direction = Vector2(
		data.get("directionX", 1),
		data.get("directionY", 1)
	)

	self.controllable = is_controllable
	self.current_map = map


func _move_towards_target(delta: float) -> void:
	position = position.move_toward(target_position, move_speed * delta)

	if position == target_position:
		if current_map:
			map_position = current_map.world_to_grid(position)
		is_moving = false
		current_direction = Vector2.ZERO
		movement_finished.emit(self)


func move_to(direction: Vector2) -> void:
	if not current_map:
		return

	var movement_direction: Vector2i = Vector2i(direction)
	var new_world_position = current_map.move_entity(self, movement_direction)

	if new_world_position != position:
		is_moving = true
		current_direction = direction
		target_position = new_world_position

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
		last_valid.get("directionX", current_direction.x),
		last_valid.get("directionY", current_direction.y)
	)

	is_moving = false
	target_position = position


func set_controllable(value: bool) -> void:
	controllable = value
	_update_camera_state()


func _update_camera_state() -> void:
	if camera:
		camera.enabled = controllable
