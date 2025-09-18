extends Node


@export_group("Settings")
@export var game_scene: PackedScene


func _ready() -> void:
	Network.handlers = [
		[Packets.SELECT_ACTOR, _handle_select_actor]
	]


func _handle_select_actor(data: Dictionary) -> void:
	if not data.get("success", false):
		Alert.show(data.get("message"))
		return

	var message = data.get("message")
	if message != null:
		Alert.show(message)

	Network.clear_handlers()

	get_tree().change_scene_to_packed(game_scene)
