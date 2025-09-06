extends Control


@export var actor_list_ui: ActorListUi
@export var create_actor_ui: CreateActorUi


func _ready() -> void:
	Network.registry = [
		[Packets.ACTOR_LIST, actor_list_ui.handle_list],
		[Packets.CREATE_ACTOR, create_actor_ui.handle],
		[Packets.DELETE_ACTOR, actor_list_ui.handle_delete]
	]
