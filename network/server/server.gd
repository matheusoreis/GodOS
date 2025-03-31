extends Node


signal peer_connected(id: int)
signal peer_disconnected(id: int)


var _enet: ENetMultiplayerPeer


func start_server() -> void:
	_setup_enet()

	_enet.peer_connected.connect(_peer_connected)
	_enet.peer_disconnected.connect(_peer_disconnected)


func _setup_enet() -> void:
	_enet = ENetMultiplayerPeer.new()
	var error = _enet.create_server(
		Constants.connection_port,
		Constants.max_connections
	)

	if error != OK:
		print("Erro ao iniciar o servidor ENet:", error)
		return

	multiplayer.multiplayer_peer = _enet
	print("Servidor iniciado com sucesso na porta: ", Constants.connection_port)


func _peer_connected(pid: int) -> void:
	pass


func _peer_disconnected(pid: int) -> void:
	pass
