class_name BootCanvas
extends CanvasLayer


@export var _client: Client
@export var _server: Server


func _ready() -> void:
	self._client.pressed.connect(_on_client_button_pressed)
	self._server.pressed.connect(_on_server_button_pressed)

	self._client.client_error.connect(_on_client_error)
	self._server.server_error.connect(_on_server_error)


func _on_client_error(error: String) -> void:
	print("Client error: %s" % error)


func _on_server_error(error: String) -> void:
	print("Server error: %s" % error)


func _on_client_button_pressed() -> void:
	self._client.start_client()
	self.hide()


func _on_server_button_pressed() -> void:
	self._server.start_server()
	self.hide()
