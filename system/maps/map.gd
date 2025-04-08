class_name Map
extends Node2D


@export_group("Objects")
@export var tilemaps: Array[TileMapLayer]
@onready var spawns: Node2D = $spawns

@export_group("Attributes")
@export var id: String
@export var identifier: String
@export var map_size: Vector2

var actors: Dictionary


func add_actor(actor: Actor) -> void:
	if actors.has(actor.id):
		return

	spawns.add_child(actor)
	actors[actor.id] = actor


func remove_actor(actor_id: int) -> void:
	if not actors.has(actor_id):
		return

	var actor_instance: Actor = actors[actor_id]
	actor_instance.queue_free()
	actors.erase(actor_id)
