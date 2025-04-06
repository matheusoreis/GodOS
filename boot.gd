class_name Main
extends Control

@export_group("Network")
@onready var _client: Client = $Network/Client
@onready var _server: Server = $Network/Server

@export_group("Objects")
@onready var _boot: VBoxContainer = $Boot
@onready var _start_client_button: Button = $Boot/Client
@onready var _start_server_button: Button = $Boot/Server
@onready var _menu_interface: CanvasLayer = $MenuInterface
@onready var _game_interface: CanvasLayer = $GameInterface

@export_group("Variables")
@export var minimize_server: bool = false
@export var is_release: bool = false


func _ready() -> void:
	if is_release:
		_start_client_in_release()
	else:
		_setup_boot_ui()


func _setup_boot_ui() -> void:
	if _boot:
		_boot.visible = true

	if _start_client_button:
		_start_client_button.pressed.connect(
			func():
				if _boot:
					_boot.queue_free()

				_menu_interface.visible = true
				_game_interface.visible = false

				_client.start_client()
		)

	if _start_server_button:
		_start_server_button.pressed.connect(
			func():
				if _boot:
					_boot.queue_free()

				if minimize_server:
					get_tree().root.mode = Window.MODE_MINIMIZED

				_server.start_server()
		)

		# TODO: Fazer a tela de desconexão.
		_client.connection_failed.connect(
			func():
				pass
		)

		_client.server_disconnected.connect(
			func():
				pass
		)


func _start_client_in_release() -> void:
	if _boot:
		_boot.queue_free()

	_client.start_client()
