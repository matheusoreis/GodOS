extends State


@export_group("Components")
@export var _entity: Entity
@export var _sprite: Sprite2D
@export var _animation: AnimationPlayer


func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:
	# Parado para a esquerda
	if _entity.last_direction.x < 0:
		_animation.play("stopped_left")

	# Parado para cima
	elif _entity.last_direction == Vector2.UP:
		_animation.play("stopped_up")

	# Parado para a direita
	elif _entity.last_direction.x > 0:
		_animation.play("stopped_right")

	# PArado para baixo
	elif _entity.last_direction.y > 0:
		_animation.play("stopped_down")


func _on_next_transitions() -> void:
	if _entity.velocity != Vector2.ZERO:
		transition.emit("walking")


func _on_enter() -> void:
	print("Entrou no estado de Stopped")


func _on_exit() -> void:
	_animation.stop()
