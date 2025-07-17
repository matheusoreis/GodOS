# Client
#
#	Autor: Matheus Reis
# Github: /matheusoreis
#
# Apache License 2.0

class_name Client
extends Button


# Sinal para notificar erros de conexão
signal client_error(error: String)


# Instância do peer multiplayer (ENet)
var _multiplayer_peer: ENetMultiplayerPeer
# Endereço do host do servidor
var _host: String
# Porta do servidor
var _port: int


func _init() -> void:
	_host = ClientConstants.host
	_port = ClientConstants.port


func _ready() -> void:
	# Cria o peer ENet para comunicação
	_multiplayer_peer = ENetMultiplayerPeer.new()

	# Conecta sinais de rede aos métodos de callback
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


# Inicia o cliente
func start_client() -> void:
	# Tenta criar o cliente ENet e conectar ao servidor
	var error = _multiplayer_peer.create_client(_host, _port)
	if error:
		client_error.emit(error)

	# Define o peer multiplayer para o sistema
	multiplayer.multiplayer_peer = _multiplayer_peer
	# Salva o ID único do cliente
	ClientGlobals.peer_id = _multiplayer_peer.get_unique_id()


# Callback quando conectado ao servidor
func _on_connected_to_server() -> void:
	print("Conectado ao servidor, peer: %d" % ClientGlobals.peer_id)


# Callback quando falha ao conectar
func _on_connection_failed() -> void:
	client_error.emit("Falha ao se conectar ao servidor %s:%d" % [_host, _port])


# Callback quando desconecta do servidor
func _on_server_disconnected() -> void:
	# Limpa o peer multiplayer
	multiplayer.multiplayer_peer = null
	# Reseta o ID do cliente global
	ClientGlobals.peer_id = -1
