extends Node2D


func _ready() -> void:
    var packets: Array[Packet] = []
    Server.register_packets(packets)

    Server.peer_connected.connect(_on_peer_connected)
    Server.peer_disconnected.connect(_on_peer_disconnected)

    var error = Server.start_server(7000, 100)
    if error != OK:
        print("Erro ao iniciar servidor: ", error)
        get_tree().quit()


func _on_peer_connected(peer_id: int) -> void:
    print("Peer conectado: ID %d" % peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
    print("Peer desconectado: ID %d" % peer_id)
