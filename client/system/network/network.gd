extends Node

signal logger(message: String)

var _handlers: Dictionary = {}
var _socket: WebSocketPeer
var _packets: BoundedQueue

var handlers: Array:
	set(value): _set_handlers(value)


func _ready():
	_socket = WebSocketPeer.new()
	_packets = BoundedQueue.new(4096)


func connect_to_host(host: String, port: int, secure: bool = false) -> void:
	var protocol = "wss://" if secure else "ws://"
	var websocket_url = protocol + host + ":" + str(port)

	var err = _socket.connect_to_url(websocket_url)
	if err != OK:
		logger.emit("Não foi possível se conectar ao servidor!")
		return


func send_packet(id: int, data: Dictionary) -> void:
	var packet = {
		"id": id,
		"data": data
	}
	var json_string = JSON.stringify(packet)
	_socket.send_text(json_string)


func _set_handlers(value: Array) -> void:
	if value == null:
		return

	for info in value:
		_handlers[info[0]] = info[1]


func clear_handlers() -> void:
	_handlers.clear()


func _process(_delta: float):
	_socket.poll()
	var state = _socket.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN:
		_handle_open_state()
	elif state == WebSocketPeer.STATE_CLOSED:
		return


func _handle_open_state():
	while _socket.get_available_packet_count():
		var raw_data = _socket.get_packet()
		var json_string = raw_data.get_string_from_utf8()

		var result = _packets.enqueue(json_string)
		if result == FAILED:
			logger.emit("A fila de pacotes está cheia, descartando pacotes")

	if _packets.count > 0 && _handlers.size() > 0:
		_handle_packet(_packets.dequeue())


func _handle_packet(json_string: String) -> void:
	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		logger.emit('Erro ao analisar JSON: %s' % json.get_error_message())
		return

	var packet_data = json.data

	if not packet_data.has("id"):
		logger.emit('Campo de ID do pacote ausente')
		return

	var packet_id = packet_data.id as int

	if !_handlers.has(packet_id):
		logger.emit('Nenhum handler registrado para o pacote: %s' % packet_id)
		return

	var handler = _handlers[packet_id] as Callable
	var data = packet_data.get("data", {})

	handler.call(data)
