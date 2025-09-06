extends Node


var alert: AlertUi


func show(message: String) -> void:
	var alert_scene: PackedScene = load("res://database/ui/shared/alert.tscn")
	alert = alert_scene.instantiate()
	alert.add_message(message)

	get_tree().current_scene.add_child(alert)
