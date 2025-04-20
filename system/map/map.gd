class_name Map
extends Node2D


@export_group("Objects")
@export var tilemaps: Array[TileMapLayer]
@onready var spawns: Node2D = $spawns
@onready var actor_spawner: MultiplayerSpawner = $ActorSpawner

@export_group("Attributes")
@export var id: String
@export var identifier: String

var actors: Dictionary


func _ready() -> void:
	actor_spawner.spawn_function = spawn_actor


func spawn_actor(actor: Dictionary) -> Actor:
	var actor_pid: int = actor["pid"]

	var actor_scene: PackedScene = load("res://database/actors/actor.tscn")
	var actor_instance: Actor = actor_scene.instantiate()
	actor_instance.map = self
	actor_instance.name = str(actor["pid"])
	actor_instance.identifier = actor["name"]

	actors[actor_pid] = actor_instance

	if not actor_pid == multiplayer.get_unique_id():
		var camera: ActorCamera = actor_instance.camera
		camera.enabled = false

	return actor_instance


func despawn_actor(pid: int) -> void:
	var actor: Actor = actors[pid]
	if not actor:
		return

	actor.queue_free()
	actors.erase(pid)
