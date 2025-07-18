class_name ActorSlotInterface
extends PanelContainer


signal access_button_pressed(actor_id: int)
signal delete_button_pressed(actor_id: int)

@export_category("Nodes")
@export var _name_label: Label
@export var _access_button: Button
@export var _delete_button: Button
@export var _new_button: Button

var _create_actor_interface: CreateActorInterface
var _actor_list_interface: ActorListInterface

var _actor_data: Dictionary = {}


func _ready() -> void:
	_create_actor_interface = get_tree().root.get_node("Game/MenuCanvas/CreateActor")
	_actor_list_interface = get_tree().root.get_node("Game/MenuCanvas/ActorList")

	_access_button.pressed.connect(_on_access_button_pressed)
	_delete_button.pressed.connect(_on_delete_button_pressed)
	_new_button.pressed.connect(_on_new_button_pressed)


func get_actor_data() -> Dictionary:
	return _actor_data


func _on_access_button_pressed() -> void:
	if _actor_data.has("id"):
		access_button_pressed.emit(_actor_data["id"])


func _on_delete_button_pressed() -> void:
	if _actor_data.has("id"):
		delete_button_pressed.emit(_actor_data["id"])


func _on_new_button_pressed() -> void:
	_create_actor_interface.show()
	_actor_list_interface.hide()


func set_actor_data(actor_data: Dictionary) -> void:
	_actor_data = actor_data
	_name_label.text = actor_data.get("name", "")
	_toggle_buttons(true)


func clear_actor_data() -> void:
	_actor_data.clear()
	_name_label.text = ""
	_toggle_buttons(false)


func _toggle_buttons(show_actor_buttons: bool) -> void:
	_access_button.visible = show_actor_buttons
	_delete_button.visible = show_actor_buttons
	_new_button.visible = not show_actor_buttons
	show()
