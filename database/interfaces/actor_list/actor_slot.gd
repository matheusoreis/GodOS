class_name ActorSlotInterface
extends PanelContainer

signal access_button_pressed(data: Dictionary)
signal delete_button_pressed(data: Dictionary)


@export var name_label: Label
@export var access_button: Button
@export var delete_button: Button


var _actor_data: Dictionary = {}


func _ready() -> void:
	self.access_button.pressed.connect(_on_access_button_pressed)
	self.delete_button.pressed.connect(_on_delete_button_pressed)


func update_data(data: Dictionary) -> void:
	self._actor_data = data
	self.name_label.text = data["name"]


func _on_access_button_pressed() -> void:
	self.access_button_pressed.emit(_actor_data['id'])


func _on_delete_button_pressed() -> void:
	self.delete_button_pressed.emit(_actor_data['id'])