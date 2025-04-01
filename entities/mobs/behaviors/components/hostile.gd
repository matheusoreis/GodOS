extends Behavior


@export_group("Components")
@export var aggro_collision: Area2D

@export_group("Variables")
@export var _aggro_area: int = 100


func physics_process(delta: float) -> void:
	pass


func _on_aggro_collision_body_entered(body: Node2D) -> void:
	pass


func _on_aggro_collision_body_exited(body: Node2D) -> void:
	pass
