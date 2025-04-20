class_name Server
extends Node


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


func _setup_enet() -> Error:
	_enet = ENetMultiplayerPeer.new()

	var error: Error = _enet.create_server(
		Constants.connection_port,
		Constants.max_connections,
	)

	if error != Error.OK:
		printerr("Erro ao iniciar o servidor, código do erro:", error)
		_enet = null
		return error

	multiplayer.multiplayer_peer = _enet
	print("Servidor iniciado com sucesso na porta:", Constants.connection_port)
	return Error.OK


func _peer_connected(pid: int) -> void:
	var peer: ENetPacketPeer = _enet.get_peer(pid)
	if not peer:
		return

	Globals.connections[pid] = {
		"id": pid,
		"ip": peer.get_remote_address()
	}

	print("Nova conexão ao servidor com o ip: ", peer.get_remote_address())


func _peer_disconnected(pid: int) -> void:
	if not Globals.connections.has(pid):
		printerr("Tentativa de desconexão de um ID inexistente:", pid)
		return

	var connection: Dictionary = Globals.connections[pid]
	print("Conexão com o ip: ", connection["ip"], ", deixando o servidor!")

	var map: Map = get_tree().root.get_node('Main/Game/Map')
	map.despawn_actor(pid)

	Globals.connections.erase(pid)
