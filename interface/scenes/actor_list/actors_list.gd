class_name ActorsListUi extends PanelContainer


@export var slots_location: HBoxContainer


func update_actor_panels(max_actors: int, actors: Array) -> void:
	var select_slot_scene := load(
		"res://interface/scenes/actor_list/select_slot/actor_list_select_slot.tscn"
	) as PackedScene

	var create_slot_scene := load(
		"res://interface/scenes/actor_list/create_slot/actor_list_create_slot.tscn"
	) as PackedScene

	for child in slots_location.get_children() as Array[Node]:
		child.queue_free()

	for i in range(actors.size()):
		var data: Dictionary = actors[i]
		var slot := select_slot_preload.instantiate() as ActorListSelectSlotUi

		slot.name = str(data["id"])
		slot.actor_id = data["id"]
		slot.name_label.text = data["name"]

		slots_location.add_child(slot)

	var remaining_slots = max_actors - actors.size()
	for i in range(remaining_slots):
		var create_slot := create_slot_preload.instantiate() as ActorListCreateSlotUi
		slots_location.add_child(create_slot)


func _on_close_pressed() -> void:
	CGlobals.menu.hide_interface("actors_list")
	CGlobals.menu.show_interface("sign_in")
