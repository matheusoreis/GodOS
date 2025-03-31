extends Node


signal connected_to_server()
signal connection_failed()
signal server_disconnected()


var _enet: ENetMultiplayerPeer


func start_client() -> void:
	var error: Error = _setup_enet()
	if error != Error.OK:
		return

	multiplayer.connected_to_server.connect(
		func(): connected_to_server.emit()
	)

	multiplayer.connection_failed.connect(
		func(): connection_failed.emit()
	)

	multiplayer.server_disconnected.connect(
		func(): server_disconnected.emit()
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
