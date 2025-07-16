class_name SignInInterface
extends PanelContainer


@export var email_input: LineEdit
@export var password_input: LineEdit
@export var sign_in_button: Button
@export var sign_up_button: Button


func _ready() -> void:
	sign_in_button.pressed.connect(_on_sign_in_button_pressed)
	sign_up_button.pressed.connect(_on_sign_up_button_pressed)


func _on_sign_in_button_pressed() -> void:
	var email: String = email_input.text
	var password: String = password_input.text

	if email.length() <= 6:
		Notification.show(["O email precisa ter ao menos 6 caracteres."])
		return

	if password.length() < 3:
		Notification.show(["A senha precisa ter ao menos 3 caracteres."])
		return

	sign_in_button.disabled = true
	sign_up_button.disabled = true

	#Network.client.send(Packets.SIGN_IN, [email, password, ClientConstants.version])


func _on_sign_up_button_pressed() -> void:
	var sign_in_interface: SignInInterface = get_tree().root.get_node("Client/MenuCanvas/SignIn")
	var sign_up_interface: SignUpInterface = get_tree().root.get_node("Client/MenuCanvas/SignUp")

	sign_in_interface.hide()
	sign_up_interface.show()


func reset_form() -> void:
	sign_in_button.disabled = false
	sign_up_button.disabled = false
