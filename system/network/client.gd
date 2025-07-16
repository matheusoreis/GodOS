class_name Client
extends Button


signal client_error(error: String)


var _multiplayer_peer: ENetMultiplayerPeer
var _host: String
var _port: int


func _init() -> void:
	_host = ClientConstants.host
	_port = ClientConstants.port


func _ready() -> void:
	_multiplayer_peer = ENetMultiplayerPeer.new()

	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func start_client() -> void:
	var error = _multiplayer_peer.create_client(_host, _port)
	if error:
		client_error.emit(error)

	multiplayer.multiplayer_peer = _multiplayer_peer
	ClientGlobals.peer_id = _multiplayer_peer.get_unique_id()


func _on_connected_to_server() -> void:
	print("Conectado ao servidor, peer: %d" % ClientGlobals.peer_id)


func _on_connection_failed() -> void:
	client_error.emit("Falha ao se conectar ao servidor %s:%d" % [_host, _port])


func _on_server_disconnected() -> void:
	ClientGlobals.peer_id = -1
	print("Desconectado do servidor.")
