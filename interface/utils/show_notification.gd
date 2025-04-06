extends Node


func show(messages: Array) -> void:
	var notification_scene := load(
		"res://interface/scenes/notification/notification.tscn"
	) as PackedScene

	var notification_instance: NotificationUI = notification_scene.instantiate()
	notification_instance.message = "\n".join(messages)

	var menu: CanvasLayer = get_tree().root.get_node("Main/SharedInterface")
	menu.add_child(notification_instance)
