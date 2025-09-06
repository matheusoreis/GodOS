class_name ActorListUi
extends PanelContainer


@export var slots_location: HBoxContainer
@export var empty_slot: PackedScene
@export var actor_slot: PackedScene


func _ready() -> void:
	Network.send_packet(Packets.ACTOR_LIST, {})


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


func handle_list(data: Dictionary) -> void:
	if !data.get("success", false):
		var message: String  = data.get("message", "Erro desconhecido ao fazer login.")
		Alert.show(message)
		return

	var max_actors: int = Globals.account.get("maxActors", 0)
	if max_actors <= 0:
		Alert.show("Número máximo de personagens inválido.")
		return

	var actors = data.get("actors", null)
	if actors == null:
		Alert.show("Dados dos personagens não foram recebidos.")
		return

	update_slots(max_actors, actors)


func handle_delete(data: Dictionary) -> void:
	Network.send_packet(Packets.ACTOR_LIST, {})
	Alert.show(data["message"])
