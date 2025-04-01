class_name Aggro
extends Area2D


@onready var collision: CollisionShape2D


func set_aggro_radius(radius: int) -> void:
	var shape: CircleShape2D = collision.shape
	shape.radius = radius
