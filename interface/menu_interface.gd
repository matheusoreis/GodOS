class_name MenuInterface
extends CanvasLayer


@export_group("Objects")
@onready var sign_in: SignInInterface = $sign_in
@onready var sign_up: SignUpInterface = $sign_up
@onready var create_actor: CreateActorUI = $create_actor


func _ready() -> void:
	WindowManager.add_interface(sign_in)
	WindowManager.add_interface(sign_up)
	WindowManager.add_interface(create_actor)
