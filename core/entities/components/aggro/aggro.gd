class_name Aggro
extends Area2D


signal entered(actor: Actor)
signal exited(actor: Actor)


@export_group("Objects")
@onready var collision: CollisionShape2D = $Collision

@export_group("Attributes")
@export var _min_radius: int = 1
@export var _max_radius: int = 10


func _ready() -> void:
	var shape: CircleShape2D = collision.shape
	var radius = randi_range(_min_radius, _max_radius)
	shape.radius = radius


func _on_body_entered(body: Node2D) -> void:
	if not body is Actor:
		return

	entered.emit(body)


func _on_body_exited(body: Node2D) -> void:
	if not body is Actor:
		return

	exited.emit(body)
