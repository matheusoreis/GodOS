extends Node


signal logger(message: String)
signal connected
signal disconnected


var _handlers: Dictionary = {}
var _socket: WebSocketPeer
var _packets: BoundedQueue
var _connected := false


var handlers: Array:
	set(value): _set_handlers(value)


func _ready():
	_socket = WebSocketPeer.new()
	_packets = BoundedQueue.new(4096)


func connect_to_host(host: String, port: int, secure: bool = false) -> Error:
	var protocol = "wss://" if secure else "ws://"
	var url = protocol + host + ":" + str(port)

	var err = _socket.connect_to_url(url)
	if err != OK:
		logger.emit("Não foi possível se conectar ao servidor!")
		return err
	return OK


func send_packet(id: int, data: Dictionary) -> void:
	var packet := {"id": id, "data": data}
	_socket.send_text(JSON.stringify(packet))


func _set_handlers(value: Array) -> void:
	if value == null:
		return
	for info in value:
		_handlers[info[0]] = info[1]


func clear_handlers() -> void:
	_handlers.clear()


func _process(_delta: float) -> void:
	_socket.poll()

	match _socket.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			if not _connected:
				_connected = true
				connected.emit()
			_handle_open_state()

		WebSocketPeer.STATE_CLOSING, WebSocketPeer.STATE_CLOSED:
			if _connected:
				_connected = false
				disconnected.emit()


func _handle_open_state():
	while _socket.get_available_packet_count() > 0:
		var json_string = _socket.get_packet().get_string_from_utf8()
		if _packets.enqueue(json_string) == FAILED:
			logger.emit("A fila de pacotes está cheia, descartando pacotes")

	if _packets.count > 0 and _handlers.size() > 0:
		_handle_packet(_packets.dequeue())


func _handle_packet(json_string: String):
	var json = JSON.new()
	if json.parse(json_string) != OK:
		logger.emit("Erro ao analisar JSON")
		return

	var data = json.data
	if not data.has("id"):
		logger.emit("Pacote sem id")
		return

	var id := int(data.id)
	if not _handlers.has(id):
		logger.emit("Nenhum handler pra pacote %s" % id)
		return

	_handlers[id].call(data.get("data", {}))
