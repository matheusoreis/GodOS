extends Node2D


func _ready() -> void:
    var packets: Array[Packet] = []
    Client.register_packets(packets)

    Client.peer_connected.connect(_on_peer_connected)
    Client.peer_disconnected.connect(_on_peer_disconnected)

    var error = Client.start_client("127.0.0.1", 7000)
    if error != OK:
        print("Erro ao iniciar cliente: ", error)
        get_tree().quit()


func _on_peer_connected(_peer_id: int) -> void:
    pass


func _on_peer_disconnected(_peer_id: int) -> void:
    pass
