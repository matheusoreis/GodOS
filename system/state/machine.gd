class_name StateMachine
extends Node2D


@export var initial_state : State

var states : Dictionary = {}
var current_state : State
var current_state_name : String


func _ready() -> void:
	# Procura as nodes de estado e adiciona ao dicionário
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transition.connect(transition_to)

	# Configura o estado inicial
	if initial_state:
		current_state = initial_state
		current_state_name = current_state.name.to_lower()
		initial_state._on_enter()


func _process(delta : float) -> void:
	if current_state:
		current_state._on_process(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state._on_physics_process(delta)
		current_state._on_next_transitions()


func transition_to(node_state_name : String) -> void:
	if node_state_name == current_state_name:
		return

	var new_node_state = states.get(node_state_name.to_lower())

	if !new_node_state:
		return

	if current_state:
		current_state._on_exit()

	new_node_state._on_enter()

	current_state = new_node_state
	current_state_name = current_state.name.to_lower()
