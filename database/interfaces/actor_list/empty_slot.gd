class_name EmptyActorSlotInterface
extends PanelContainer


@export var new_button: Button


func _ready() -> void:
	new_button.pressed.connect(_on_new_button_pressed)


func _on_new_button_pressed() -> void:
	var create_actor_interface: CreateActorInterface = get_tree().root.get_node("Game/MenuCanvas/CreateActor")
	var actor_list_interface: ActorListInterface = get_tree().root.get_node("Game/MenuCanvas/ActorList")

	create_actor_interface.show()
	actor_list_interface.hide()
