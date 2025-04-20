class_name ActorCamera
extends Camera2D


enum ZoomLevel {
	NORMAL,
	FAR,
	EXTREME
}

var zoom_levels: Dictionary = {
	ZoomLevel.NORMAL: 2,
	ZoomLevel.FAR: 3,
	ZoomLevel.EXTREME: 4
}

@export var actor: Actor

@export_group("Variables")
@export var zoom_speed: float = 0.1
@export var current_zoom: ZoomLevel


func _ready() -> void:
	_apply_zoom()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		_zoom_in()
	elif event.is_action_pressed("zoom_out"):
		_zoom_out()


func _zoom_in() -> void:
	if current_zoom > ZoomLevel.NORMAL:
		current_zoom -= 1
		_apply_zoom()


func _zoom_out() -> void:
	if current_zoom < ZoomLevel.EXTREME:
		current_zoom += 1
		_apply_zoom()


func _apply_zoom() -> void:
	var target_zoom = zoom_levels[current_zoom]

	var tween = create_tween()
	tween.tween_property(
		self, "zoom", Vector2(target_zoom, target_zoom), zoom_speed
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_OUT
	)
