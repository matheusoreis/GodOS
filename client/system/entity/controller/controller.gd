class_name EntityController
extends Node


@export var entity: Entity
@export var input_enabled: bool = true


func _ready():
	if not entity:
		entity = get_parent() as Entity
	
	if not entity:
		return


func _process(_delta: float):
	if not input_enabled or not entity or not entity.controllable:
		return
	
	# Pega o vetor de input
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		input_vector = Vector2.UP
	elif Input.is_action_pressed("ui_down"):
		input_vector = Vector2.DOWN
	elif Input.is_action_pressed("ui_left"):
		input_vector = Vector2.LEFT
	elif Input.is_action_pressed("ui_right"):
		input_vector = Vector2.RIGHT
	
	if input_vector != Vector2.ZERO and not entity.is_moving:
		entity.move_to(input_vector)


func enable_input():
	input_enabled = true


func disable_input():
	input_enabled = false
