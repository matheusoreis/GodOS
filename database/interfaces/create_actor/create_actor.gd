class_name CreateActorInterface
extends PanelContainer


@export var name_input: LineEdit
@export var create_button: Button
@export var back_button: Button


func _ready() -> void:
	create_button.pressed.connect(_on_create_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)


func _on_create_button_pressed() -> void:
	var name: String = name_input.text

	if name.length() <= 3:
		Notification.show(["O nome precisa ter ao menos 4 caracteres."])
		return

	#Network.client.send(Packets.CREATE_ACTOR, [name])


func _on_back_button_pressed() -> void:
	var actor_list_interface: SignInInterface = get_tree().root.get_node("Client/MenuCanvas/ActorList")
	var create_actor_interface: SignUpInterface = get_tree().root.get_node("Client/MenuCanvas/CreateActor")

	actor_list_interface.show()
	create_actor_interface.hide()
