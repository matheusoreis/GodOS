class_name Boot
extends VBoxContainer

signal start_client_pressed()
signal start_server_pressed()

@export_group("Objects")
@onready var _start_client_button: Button = $Client
@onready var _start_server_button: Button = $Server


func _ready() -> void:
	_start_client_button.pressed.connect(_start_client)
	_start_server_button.pressed.connect(_start_server)


func _start_client() -> void:
	start_client_pressed.emit()
	queue_free()


func _start_server() -> void:
	start_server_pressed.emit()
	queue_free()
