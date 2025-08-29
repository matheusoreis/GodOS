extends Node2D


signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)


var enet: ENetConnection
var _peer: ENetPacketPeer

var _packets: Dictionary[int, Packet] = {}


func register_packets(packets: Array[Packet]) -> void:
    for packet in packets:
        if _packets.has(packet.packet_id):
            push_warning("Packet ID %d já está registrado! Ignorando duplicata." % packet.packet_id)
            continue

        _packets[packet.packet_id] = packet
        print("Packet registrado: ID %d" % packet.packet_id)


func start_client(host: String, port: int) -> Error:
    enet = ENetConnection.new()
    var error = enet.create_host()
    if error != OK:
        push_error("Falha ao criar cliente: %s" % error_string(error))
        return error

    _peer = enet.connect_to_host(host, port)
    if not _peer:
        push_error("Falha ao conectar no servidor %s:%d" % [host, port])
        return ERR_CANT_CONNECT

    return OK


func _process(_delta: float) -> void:
    if not enet:
        return

    var event = enet.service()
    if event.is_empty():
        return

    _handle_event(event)


func _handle_event(event: Array) -> void:
    var event_type = event[0]
    var event_peer = event[1] as ENetPacketPeer

    match event_type:
        ENetConnection.EventType.EVENT_ERROR:
            _on_peer_error(event_peer)
        ENetConnection.EventType.EVENT_CONNECT:
            _on_peer_connected(event_peer)
        ENetConnection.EventType.EVENT_DISCONNECT:
            _on_peer_disconnected(event_peer)
        ENetConnection.EventType.EVENT_RECEIVE:
            _on_data_received(event_peer)


func _on_peer_connected(peer: ENetPacketPeer) -> void:
    var peer_id = peer.get_instance_id()
    peer_connected.emit(peer_id)


func _on_peer_disconnected(peer: ENetPacketPeer) -> void:
    var peer_id = peer.get_instance_id()
    peer_disconnected.emit(peer_id)


func _on_data_received(peer: ENetPacketPeer) -> void:
    var packet_data = peer.get_packet()
    if packet_data.size() > 0:
        _handle_packet(packet_data)


func _on_peer_error(peer: ENetPacketPeer) -> void:
    push_error("Erro de conexão com o servidor")
    self.peer = null


func _handle_packet(packet_data: PackedByteArray) -> void:
    var data = JSON.parse_string(packet_data.get_string_from_utf8())

    if typeof(data) != TYPE_DICTIONARY:
        push_warning("Dados recebidos não são um dicionário válido")
        return

    if not data.has("id") or not data.has("data"):
        push_warning("Pacote mal formatado, faltam id ou data")
        return

    var id = data["id"]
    var packet_args = data["data"]

    if typeof(id) != TYPE_INT:
        push_warning("id deve ser um inteiro")
        return

    if typeof(packet_args) != TYPE_DICTIONARY:
        push_warning("data deve ser um dicionário")
        return

    if not _packets.has(id):
        push_warning("Packet ID %d não registrado" % id)
        return

    var packet: Packet = _packets[id]
    packet.handle(packet_args, -1)


func disconnect_peer() -> void:
    if _peer:
        _peer.peer_disconnect_later()
        _peer = null


func send_to_peer(packet_id: int, data: Dictionary) -> Error:
    if not _peer or _peer.get_state() != ENetPacketPeer.STATE_CONNECTED:
        return ERR_CONNECTION_ERROR

    var packet_data = {
        "id": packet_id,
        "data": data
    }

    var json_string = JSON.stringify(packet_data)
    var packet_bytes = json_string.to_utf8_buffer()

    return _peer.send(0, packet_bytes, ENetPacketPeer.FLAG_RELIABLE)


func is_peer_connected() -> bool:
    return _peer != null and _peer.get_state() == ENetPacketPeer.STATE_CONNECTED
