extends Control


@export var actor_list_ui: ActorListUi
@export var create_actor_ui: CreateActorUi


func _ready() -> void:
	Network.registry = [
		[Packets.ACTOR_LIST, actor_list_ui.handle_list],
		[Packets.CREATE_ACTOR, create_actor_ui.handle],
		[Packets.DELETE_ACTOR, actor_list_ui.handle_delete],
		[Packets.SELECT_ACTOR, _select_actor],
		[Packets.ACTORS_TO_ME, _actors_to_me],
		[Packets.ME_TO_ACTORS, _me_to_actors],
	]


func _select_actor(data: Dictionary) -> void:
	print(data)


func _actors_to_me(data: Array) -> void:
	print(data)
	

func _me_to_actors(data: Dictionary) -> void:
	print(data)
