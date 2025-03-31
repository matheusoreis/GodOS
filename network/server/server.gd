extends Node


signal peer_connected(id: int)
signal peer_disconnected(id: int)


var _enet: ENetMultiplayerPeer


func start_server() -> void:
	var error: Error = _setup_enet()
	if error != Error.OK:
		return

	_enet.peer_connected.connect(
		_peer_connected
	)

	_enet.peer_disconnected.connect(
		_peer_disconnected
	)

	print("Servidor iniciado com sucesso na porta:", Constants.connection_port)


func _setup_enet() -> Error:
	_enet = ENetMultiplayerPeer.new()

	var error: Error = _enet.create_server(
		Constants.connection_port,
		Constants.max_connections
	)

	if error != Error.OK:
		printerr("Erro ao iniciar o servidor, código do erro:", error)
		_enet = null
		return error

	multiplayer.multiplayer_peer = _enet
	return Error.OK


func _peer_connected(pid: int) -> void:
	var peer: ENetPacketPeer = _enet.get_peer(pid)
	if not peer:
		return

	Globals.connections[pid] = {
		"id": pid,
		"peer": peer
	}

	print("Nova conexão ao servidor com o ip: ", peer.get_remote_address())
	peer_connected.emit(pid)


func _peer_disconnected(pid: int) -> void:
	if not Globals.connections.has(pid):
		printerr("Tentativa de desconexão de um ID inexistente:", pid)
		return

	var connection: Dictionary = Globals.connections[pid]
	var connection_peer: ENetPacketPeer = connection.get("peer", null)

	Globals.connections.erase(pid)

	print("Conexão com o ip: ", connection_peer.get_remote_address(), ", deixando o servidor!")
	peer_disconnected.emit(pid)
