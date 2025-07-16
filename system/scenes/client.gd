class_name ClientScene
extends Control


var _multiplayer_peer: ENetMultiplayerPeer


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	

func connect_to_server() -> void:
	var port: int = ServerConstants.port
	var max_peers: int = ServerConstants.max_peers
	
	_multiplayer_peer = ENetMultiplayerPeer.new()
	
	var error = _multiplayer_peer.create_server(port, max_peers)
	if error:
		print(error)
	
	multiplayer.multiplayer_peer = _multiplayer_peer


func _on_peer_connected(peer_id: int) -> void:
	print("Novo cliente conectado: ", peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	print("Failed to connect to the server: ", peer_id)
