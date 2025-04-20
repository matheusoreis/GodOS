class_name Entity
extends CharacterBody2D


@export_group("Components")
@export var sprite: Sprite2D
@export var animation: AnimationPlayer
@export var state_machine: StateMachine

@export_group("Variables")
@export var id: int
@export var identifier: String
@export var move_speed: int
var map: Map

var last_direction: Vector2
var direction: Vector2 = Vector2.DOWN
var last_velocity: Vector2 = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return

	move_and_slide()


func move(new_direction: Vector2, speed_bonus: int = 0) -> void:
	if not multiplayer.is_server():
		return

	direction = new_direction.normalized()
	var entity_velocity = new_direction.normalized() * (move_speed + speed_bonus)
	velocity = entity_velocity
