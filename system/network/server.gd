class_name Server
extends Button


signal server_error(error: String)


var _multiplayer_peer: ENetMultiplayerPeer
var _port: int
var _max_peers: int


func _init() -> void:
	_port = ServerConstants.port
	_max_peers = ServerConstants.max_peers


func _ready() -> void:
	_multiplayer_peer = ENetMultiplayerPeer.new()

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func start_server() -> void:
	var error = _multiplayer_peer.create_server(_port, _max_peers)
	if error:
		server_error.emit(error)

	multiplayer.multiplayer_peer = _multiplayer_peer


func _on_peer_connected(peer_id: int) -> void:
	if not multiplayer.is_server():
		return

	print("Novo peer conectado ao servidor: %d" % peer_id)

	var connected_peers = multiplayer.get_peers().size()
	print("Clientes conectados: %d / %d" % [connected_peers, _max_peers])


func _on_peer_disconnected(peer_id: int) -> void:
	print("Peer desconectado do servidor: %d" % peer_id)
