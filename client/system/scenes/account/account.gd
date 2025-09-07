extends Control


@export var actor_list_ui: ActorListUi
@export var create_actor_ui: CreateActorUi


func _ready() -> void:
	Network.registry = [
		[Packets.ACTOR_LIST, actor_list_ui.handle_list],
		[Packets.CREATE_ACTOR, create_actor_ui.handle],
		[Packets.DELETE_ACTOR, actor_list_ui.handle_delete],
		[Packets.SELECT_ACTOR, _select_actor],
	]


func _select_actor(data: Dictionary) -> void:
	#var error = data.get("success", false)
	#if error == false:
		#Alert.show(data.get("message", "Erro desconhecido ao selecionar o personagem."))
		#return
	
	var map = data.get("map", null)
	if map == null:
		Alert.show("Dados do mapa não foram recebidos.")
		return
	
	var actor = data.get("actor", null)
	if actor == null:
		Alert.show("Dados do personagens não foram recebidos.")
		return
		
	Globals.map = map
	Globals.actor = actor
	
	get_tree().change_scene_to_file("res://system/scenes/game/game.tscn")
