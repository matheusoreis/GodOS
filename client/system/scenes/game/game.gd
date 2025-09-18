class_name Game
extends Node2D


var current_map: Map


func load_map(map_file: String, identifier: String) -> void:
	if current_map:
		current_map.queue_free()
		current_map = null

	var packed_map: PackedScene = load("res://database/maps/%s.tscn" % map_file)
	if not packed_map:
		push_error("Falha ao carregar o mapa %s" % map_file)
		return

	current_map = packed_map.instantiate()
	current_map.identifier = identifier
	add_child(current_map)
