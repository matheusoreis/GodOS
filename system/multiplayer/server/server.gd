extends Node2D


signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)


var enet: ENetConnection
var connections: Dictionary[int, Dictionary] = {}

var _packets: Dictionary[int, Packet] = {}


func register_packets(packets: Array[Packet]) -> void:
    for packet in packets:
        if _packets.has(packet.packet_id):
            push_warning("Packet ID %d já está registrado! Ignorando duplicata." % packet.packet_id)
            continue

        _packets[packet.packet_id] = packet
        print("Packet registrado: ID %d" % packet.packet_id)


func start_server(port: int, max_connections: int) -> Error:
   connections.clear()

   enet = ENetConnection.new()
   var error = enet.create_host_bound('0.0.0.0', port, max_connections)
   if error != OK:
       push_error("Falha ao iniciar servidor na porta %d: %s" % [port, error_string(error)])
       return error

   print("Servidor iniciado na porta %d (max %d peers)" % [port, max_connections])
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
   var peer = event[1] as ENetPacketPeer

   match event_type:
       ENetConnection.EventType.EVENT_ERROR:
           _on_peer_error(peer)
       ENetConnection.EventType.EVENT_CONNECT:
           _on_peer_connected(peer)
       ENetConnection.EventType.EVENT_DISCONNECT:
           _on_peer_disconnected(peer)
       ENetConnection.EventType.EVENT_RECEIVE:
           _on_data_received(peer)


func _on_peer_connected(peer: ENetPacketPeer) -> void:
   var peer_id = peer.get_instance_id()

   connections[peer_id] = {
       "peer": peer,
       "connected_at": Time.get_ticks_msec()
   }

   peer_connected.emit(peer_id)


func _on_peer_disconnected(peer: ENetPacketPeer) -> void:
   var peer_id = peer.get_instance_id()

   if not connections.has(peer_id):
       return

   connections.erase(peer_id)
   peer_disconnected.emit(peer_id)


func _on_data_received(peer: ENetPacketPeer) -> void:
   var peer_id = peer.get_instance_id()

   var packet_data = peer.get_packet()
   if packet_data.size() > 0:
       _handle_packet(packet_data, peer_id)


func _on_peer_error(peer: ENetPacketPeer) -> void:
   var peer_id = peer.get_instance_id()
   push_error("Erro de rede com peer %d" % peer_id)


func _handle_packet(packet_data: PackedByteArray, peer_id: int) -> void:
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
    packet.handle(packet_args, peer_id)


func disconnect_peer(peer_id: int) -> void:
   if not connections.has(peer_id):
       push_warning("Tentativa de desconectar peer inexistente: %d" % peer_id)
       return

   var connection = connections[peer_id]
   var peer = connection["peer"] as ENetPacketPeer

   peer.peer_disconnect_later()
   connections.erase(peer_id)
   peer_disconnected.emit(peer_id)


func send_to_peer(peer_id: int, packet_id: int, data: Dictionary) -> Error:
   if not connections.has(peer_id):
       return ERR_INVALID_PARAMETER

   var connection = connections[peer_id]
   var peer = connection["peer"] as ENetPacketPeer

   var packet_data = {
       "id": packet_id,
       "data": data
   }

   var json_string = JSON.stringify(packet_data)
   var packet_bytes = json_string.to_utf8_buffer()

   return peer.send(0, packet_bytes, ENetPacketPeer.FLAG_RELIABLE)


func is_peer_connected(peer_id: int) -> bool:
   return connections.has(peer_id)
