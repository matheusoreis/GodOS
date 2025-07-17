class_name BootCanvas
extends CanvasLayer


@export var _client: Client
@export var _server: Server


func _ready() -> void:
	%BootCanvas.show()
	%SharedCanvas.hide()
	%GameCanvas.hide()
	%MenuCanvas.hide()

	_client.pressed.connect(_on_client_button_pressed)
	_server.pressed.connect(_on_server_button_pressed)

	_client.client_error.connect(_on_client_error)
	_server.server_error.connect(_on_server_error)


func _on_client_error(error: String) -> void:
	print("Client error: %s" % error)


func _on_server_error(error: String) -> void:
	print("Server error: %s" % error)


func _on_client_button_pressed() -> void:
	_client.start_client()
	hide()

	%SharedCanvas.show()
	%MenuCanvas.show()

func _on_server_button_pressed() -> void:
	_server.start_server()
	hide()
