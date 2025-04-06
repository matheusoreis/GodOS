class_name ActorListSelectSlotUi extends PanelContainer


@export_group("Objects")
@export var name_label: Label
@export var select_button: Button
@export var delete_button: Button


var actor_id: int


func _on_select_pressed() -> void:
	select_button.disabled = true
	delete_button.disabled = true

	#Network.client.send(
		#Packets.SELECT_ACTOR, [actor_id]
	#)


func _on_delete_pressed() -> void:
	pass
	#var confirmation: ConfirmationInterface = Confirmation.show(
		#"Você está apagando o seu personagem, deseja continuar?"
	#)
#
	#confirmation.confirmed.connect(
		#func(_value: int):
			#select_button.disabled = true
			#delete_button.disabled = true
#
			#Network.client.send(
			#Packets.DELETE_ACTOR, [actor_id]
		#)
	#)
