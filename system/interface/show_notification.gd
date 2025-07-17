extends Node


func show(messages: Array[String]) -> void:
	var notification_scene: PackedScene = preload(
		"res://database/interfaces/notification/notification.tscn"
	)

	var notification_scene_instance: NotificationInterface = notification_scene.instantiate()
	notification_scene_instance.message.text = "\n".join(messages)

	var shared_canvas: CanvasLayer = get_tree().root.get_node("Game/SharedCanvas")
	shared_canvas.add_child(notification_scene_instance)
