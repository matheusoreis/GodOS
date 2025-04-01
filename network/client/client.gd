class_name Client
extends Node


var _enet: ENetMultiplayerPeer


func start_client() -> void:
	var error: Error = _setup_enet()
	if error != Error.OK:
		return

	multiplayer.connected_to_server.connect(
		_connected_to_server
	)

	multiplayer.connection_failed.connect(
		_connection_failed
	)

	multiplayer.server_disconnected.connect(
		_server_disconnected
	)


func _setup_enet() -> Error:
	_enet = ENetMultiplayerPeer.new()
	var error: Error = _enet.create_client(
		Constants.connection_address,
		Constants.connection_port
	)

	if error != Error.OK:
		_enet = null
		return error

	multiplayer.multiplayer_peer = _enet
	return Error.OK


func _connected_to_server() -> void:
	print("Cliente conectado ao servidor!")


func _connection_failed() -> void:
	print("Falha ao se conectar no servidor!")


func _server_disconnected() -> void:
	print("Falha na conexão com o servidor, servidor fechado!")
