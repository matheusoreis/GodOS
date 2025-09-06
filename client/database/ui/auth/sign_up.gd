class_name SignUpUi
extends PanelContainer


@export var username_line: LineEdit
@export var email_line: LineEdit
@export var password_line: LineEdit
@export var re_password_line: LineEdit

@export var sign_in_button: Button
@export var confirm_button: Button

@export var sign_in_ui: SignInUi


func _on_sign_in_pressed() -> void:
	hide()
	sign_in_ui.show()


func _on_confirm_pressed() -> void:
	var username: String = username_line.text
	var email: String = email_line.text
	var password: String = password_line.text
	var re_password: String = re_password_line.text

	if username.length() < Constants.min_identifier_length:
		Alert.show("Ops! O usuário deve ter ao menos " + str(Constants.min_identifier_length) + ", caracteres.")
		return

	if email.length() < Constants.min_email_length:
		Alert.show("Ops! O Email deve ter ao menos " + str(Constants.min_identifier_length) + ", caracteres.")
		return

	if password.length() < Constants.min_password_length:
		Alert.show("Ops! A senha deve ter ao menos " + str(Constants.min_password_length) + ", caracteres.")
		return

	if re_password.length() < Constants.min_password_length:
		Alert.show("Ops! A repetição da senha deve ter ao menos " + str(Constants.min_password_length) + ", caracteres.")
		return

	if password != re_password:
		Alert.show("Ops! Certifique-se de que as senhas digitadas são iguais.")
		return

	set_form_interactive(false)

	Network.send_packet(Packets.SIGN_UP, {
		"username": username,
		"email": email,
		"password": password
	})


func set_form_interactive(value: bool) -> void:
	username_line.editable = value
	email_line.editable = value
	password_line.editable = value
	re_password_line.editable = value

	sign_in_button.disabled = !value
	confirm_button.disabled = !value


func handle(data: Dictionary) -> void:
	set_form_interactive(true)

	var error = data.get("success", false)
	if error == false:
		Alert.show(data.get("message", "Erro desconhecido ao fazer login."))
		return
	
	var message = data.get("message", null)
	if message == null:
		Alert.show("Erro! Os dados da mensagem não foram recebidos.")
		return

	Alert.show(message)

	hide()
	sign_in_ui.show()
