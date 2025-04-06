class_name Main
extends Control

@export_group("Network")
@onready var _client: Client = $Network/Client
@onready var _server: Server = $Network/Server

@export_group("Objects")
@onready var _boot: VBoxContainer = $Boot
@onready var _start_client_button: Button = $Boot/Client
@onready var _start_server_button: Button = $Boot/Server
@onready var menu_interface: CanvasLayer = $MenuInterface
@onready var game_interface: CanvasLayer = $GameInterface
@onready var _game: Node2D = $Game

@export_group("Variables")
@export var minimize_server: bool = false
@export var is_release: bool = false

@export_group("Loaders")
@export var _map_scenes: Array[PackedScene]


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

				menu_interface.visible = true
				game_interface.visible = false

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
				_load_data()
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


func _load_data() -> void:
	_load_maps()


func _load_maps() -> void:
	Globals.maps.clear()

	if _map_scenes.is_empty():
		return

	for scene in _map_scenes:
		var map_instance: Map = scene.instantiate()
		var scene_path = scene.resource_path
		var scene_file = scene_path.get_file()
		var scene_name = scene_file.get_basename()

		map_instance.id = scene_name
		map_instance.name = scene_name

		Globals.maps[scene_name] = map_instance
		_game.add_child(map_instance)
