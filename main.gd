class_name Main
extends Control

@export_group("Interfaces")
@onready var boot_interface: Boot = $Boot
@onready var menu_interface: MenuInterface = $MenuInterface
@onready var game_interface: GameInterface = $GameInterface

@export_group("Objects")
@onready var game: Game = $Game
@onready var network: Network = $Network

@export_group("Variables")
@export var minimize_server: bool = false
@export var debug_server: bool = false


func _ready() -> void:
	boot_interface.start_client_pressed.connect(_start_client)
	boot_interface.start_server_pressed.connect(_start_server)


func _start_client() -> void:
	menu_interface.visible = true
	game_interface.visible = false

	network.start_client()


func _start_server() -> void:
	if minimize_server:
		get_tree().root.mode = Window.MODE_MINIMIZED

	if debug_server:
		game.show()

	network.start_server()
