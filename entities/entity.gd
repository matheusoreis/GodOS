class_name Entity
extends CharacterBody2D


@export_group("Objects")
@export var _sprite: Sprite2D
@export var _animation: AnimationPlayer

@export_group("Variables")
@export var _move_speed: float = 50
@export var _last_direction: Vector2 = Vector2.RIGHT


func _physics_process(delta: float) -> void:


	#if multiplayer.is_server():
	move_and_slide()

	#if velocity != Vector2.ZERO:
		#_last_direction = velocity.normalized()
		#_play_walking_animation()
	#else:
		#_play_stopped_animation()


func _play_walking_animation() -> void:
	if abs(velocity.x) >= abs(velocity.y):
		_sprite.flip_h = velocity.x < 0
		_animation.play("walking_side")
	elif velocity.y > 0:
		_animation.play("walking_down")
	else:
		_animation.play("walking_up")


func _play_stopped_animation() -> void:
	if abs(_last_direction.x) >= abs(_last_direction.y):
		_animation.play("stopped_side")
	elif _last_direction.y > 0:
		_animation.play("stopped_down")
	else:
		_animation.play("stopped_up")
