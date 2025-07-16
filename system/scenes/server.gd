class_name ServerScene
extends Control


var _multiplayer_peer: ENetMultiplayerPeer


func _ready() -> void:
	var host: String = ClientConstants.host
	var port: int = ClientConstants.port
	
	_multiplayer_peer = ENetMultiplayerPeer.new()
	
	var error = _multiplayer_peer.create_client(host, port)
	if error:
		print(error)
	
	multiplayer.multiplayer_peer = _multiplayer_peer
	ClientGlobals.peer_id = _multiplayer_peer.get_unique_id()
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_connected_to_server() -> void:
	print("Successfully connected to the server: ", ClientGlobals.peer_id)


func _on_connection_failed() -> void:
	print("Failed to connect to the server: ", ClientGlobals.peer_id)


func _on_server_disconnected() -> void:
	print("Disconnected from the server: ", ClientGlobals.peer_id)
