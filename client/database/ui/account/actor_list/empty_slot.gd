class_name EmptySlotActorUi
extends PanelContainer


func _on_new_button_pressed() -> void:
	var create_actor_ui: CreateActorUi = get_tree().root.get_node("Account/Center/CreateActor")
	create_actor_ui.show()

	var actor_list_ui: ActorListUi = get_tree().root.get_node("Account/Center/ActorList")
	actor_list_ui.hide()
