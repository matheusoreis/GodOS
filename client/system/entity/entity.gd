class_name Entity
extends Node2D


signal movement_finished


@export_group("Settings")
@export var identifier: String
@export var map_position: Vector2i
@export var controllable: bool
@export var move_speed: float = 150.0


@export_group("Nodes")
@export var sprite: Sprite2D
@export var current_map: Map = null


var is_moving: bool = false
var current_direction: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	if is_moving:
		move_towards_target(delta)


func move_towards_target(delta: float) -> void:
	var direction = (target_position - position).normalized()
	position += direction * move_speed * delta
	
	var distance_to_target = position.distance_to(target_position)
	var next_distance = (position + direction * move_speed * delta).distance_to(target_position)
	
	if next_distance >= distance_to_target:
		position = target_position
		is_moving = false
		current_direction = Vector2.ZERO
		movement_finished.emit()


func move_to(direction: Vector2) -> void:
	if not current_map:
		return
	
	var movement_direction: Vector2i = Vector2i(direction)
	var new_world_position = current_map.move_entity(self, movement_direction)
	
	if new_world_position != position:
		is_moving = true
		current_direction = direction
		target_position = new_world_position
