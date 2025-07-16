class_name ActorSlotInterface
extends PanelContainer


@export var name_label: Label
@export var access_button: Button
@export var delete_button: Button


var _data: Dictionary = {}


func _ready() -> void:
	access_button.pressed.connect(_on_access_button_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)


func update_data(data: Dictionary) -> void:
	_data = data
	name_label.text = _data["name"]


func _on_access_button_pressed() -> void:
	pass
	#Network.client.send(Packets.SELECT_ACTOR, [_data["id"]])


func _on_delete_button_pressed() -> void:
	pass
	#Network.client.send(Packets.DELETE_ACTOR, [_data["id"]])
