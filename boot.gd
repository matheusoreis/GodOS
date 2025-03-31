class_name Main
extends Control


@export_group("Objects")
@export var boot: VBoxContainer
@export var start_client_button: Button
@export var start_server_button: Button

@export_group("Scenes")
@export var client: PackedScene
@export var server: PackedScene

@export_group("Variables")
@export var minimize: bool = false


func _ready() -> void:
	if not boot:
		return

	if not start_client_button:
		return

	if not start_server_button:
		return

	start_client_button.pressed.connect(
		func():
			var scene: Control = client.instantiate()
			scene.name = "main"

			get_tree().root.add_child(scene)
			queue_free()
	)

	start_server_button.pressed.connect(
		func():
			if minimize:
				get_tree().root.mode = Window.MODE_MINIMIZED

			var scene: Control = server.instantiate()
			scene.name = "main"
			get_tree().root.add_child(scene)
			queue_free()
	)
