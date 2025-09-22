class_name SignInUi
extends PanelContainer


signal sign_up_pressed()


@export_group("Nodes")
@export var identifier_line: LineEdit
@export var password_line: LineEdit
@export var sign_up_button: Button
@export var confirm_button: Button


func _on_sign_up_pressed() -> void:
	hide()
	sign_up_pressed.emit()


func _on_confirm_pressed() -> void:
	var identifier: String = identifier_line.text
	var password: String = password_line.text

	if identifier.length() < Constants.min_identifier_length:
		Alert.show("Ops! A identificação deve ter ao menos " + str(Constants.min_identifier_length) + " caracteres.")
		return

	if password.length() < Constants.min_password_length:
		Alert.show("Ops! A senha deve ter ao menos " + str(Constants.min_password_length) + " caracteres.")
		return

	set_form_interactive(false)

	Network.send_packet(Packets.SIGN_IN, {
		"identifier": identifier,
		"password": password,
		"major": Constants.major_version,
		"minor": Constants.minor_version,
		"revision": Constants.revision_version
	})


func set_form_interactive(value: bool) -> void:
	identifier_line.editable = value
	password_line.editable = value

	sign_up_button.disabled = !value
	confirm_button.disabled = !value
