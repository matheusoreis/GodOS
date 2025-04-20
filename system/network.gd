class_name Network
extends Node

@export_group("Network")
@onready var _client: Client = $Client
@onready var _server: Server = $Server


func start_client() -> void:
	_client.start_client()


func start_server() -> void:
	_server.start_server()
