class_name Entity
extends CharacterBody2D


@export_group("Objects")
@export var _sprite: Sprite2D
@export var _animation: AnimationPlayer
@export var _state_machine: StateMachine


@export_group("Variables")
@export var identifier: String


@export_group("Attributes")
@onready var health: Health = $Attributes/Health
@onready var speed: Speed = $Attributes/Speed


var last_direction: Vector2
var direction: Vector2 = Vector2.DOWN


func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		move_and_slide()
