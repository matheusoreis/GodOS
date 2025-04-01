class_name Entity
extends CharacterBody2D


@export_group("Objects")
@export var _sprite: Sprite2D
@export var _animation: AnimationPlayer
@export var _state_machine: StateMachine

@export_group("Variables")
@export var _move_speed: float = 50

@export_group("Properties")
@export var _entity_name: String

var last_direction: Vector2
var direction: Vector2 = Vector2.DOWN


func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		move_and_slide()
