class_name Packet
extends RefCounted


var packet_id: int


func _init(id: int) -> void:
    packet_id = id


@warning_ignore("unused_parameter")
func handle(data: Dictionary, peer_id: int) -> void:
    push_error("Método handle deve ser implementado na subclasse")
