class_name ActorListUi
extends PanelContainer


@export_group("Nodes")
@export var slots_location: HBoxContainer
@export var empty_slot: PackedScene
@export var actor_slot: PackedScene


func update_slots(max_actors: int, actors: Array) -> void:
	for child in slots_location.get_children():
		child.queue_free()

	for i in range(actors.size()):
		var data: Dictionary = actors[i]

		var slot: ActorSlotUi = actor_slot.instantiate()
		slot.name = str(int(data['id']))
		slot.update_data(data)
		slots_location.add_child(slot)

	for i in range(max_actors - actors.size()):
		var slot: EmptySlotActorUi = empty_slot.instantiate()
		slots_location.add_child(slot)
