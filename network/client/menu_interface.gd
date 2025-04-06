class_name MenuInterface
extends CanvasLayer


@export_group("Objects")
@onready var sign_in: SignInInterface = $sign_in
@onready var sign_up: SignUpInterface = $sign_up


func _ready() -> void:
	print("Inicializando o window manager...")
	WindowManager.add_interface(sign_in)
	WindowManager.add_interface(sign_up)
