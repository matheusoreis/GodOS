extends State


@export_group("Components")
@export var _entity: Entity
@export var _sprite: Sprite2D
@export var _animation: AnimationPlayer


func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:
	# Movendo para a esquerda
	if _entity.velocity.x < 0:
		_sprite.flip_h = true
		_animation.play("walking_side")

	# Movendo para cima
	elif _entity.velocity.y < 0:
		_animation.play("walking_up")

	# Movendo para a direita
	elif _entity.velocity.x > 0:
		_sprite.flip_h = false
		_animation.play("walking_side")

	# Movendo para baixo
	elif _entity.velocity.y > 0:
		_animation.play("walking_down")


func _on_next_transitions() -> void:
	if _entity.direction == Vector2.ZERO:
		transition.emit("stopped")


func _on_enter() -> void:
	print("Entrou no estado de Walking")


func _on_exit() -> void:
	_animation.stop()
