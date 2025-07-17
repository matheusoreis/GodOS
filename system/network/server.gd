# Server
#
#	Autor: Matheus Reis
# Github: /matheusoreis
#
# Apache License 2.0

class_name Server
extends Button

# Sinal para notificar erros de conexão do servidor
signal server_error(error: String)

# Instância do peer multiplayer (ENet)
var _multiplayer_peer: ENetMultiplayerPeer
# Porta do servidor
var _port: int
# Número máximo de clientes conectados
var _max_peers: int


func _init() -> void:
	_port = ServerConstants.port
	_max_peers = ServerConstants.max_peers


func _ready() -> void:
	# Cria o peer ENet para comunicação
	_multiplayer_peer = ENetMultiplayerPeer.new()

	# Conecta sinais de rede aos métodos de callback
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


# Inicia o servidor
func start_server() -> void:
	# Tenta criar o servidor ENet e aceitar conexões de clientes
	var error = _multiplayer_peer.create_server(_port, _max_peers)
	if error:
		server_error.emit(error)

	# Define o peer multiplayer para o sistema
	multiplayer.multiplayer_peer = _multiplayer_peer


# Callback quando um cliente conecta ao servidor
func _on_peer_connected(peer_id: int) -> void:
	if not multiplayer.is_server():
		return

	print("Novo peer conectado ao servidor: %d" % peer_id)

	# Mostra o número de clientes conectados
	_show_connected_peers()

# Callback quando um cliente desconecta do servidor
func _on_peer_disconnected(peer_id: int) -> void:
	print("Peer desconectado do servidor: %d" % peer_id)

	# Mostra o número de clientes conectados
	_show_connected_peers()


@rpc("authority")
func _show_connected_peers() -> void:
	# Obtém o número de clientes conectados
	var connected_peers = multiplayer.get_peers().size()
	print("Clientes conectados: %d / %d" % [connected_peers, _max_peers])