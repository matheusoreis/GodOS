class_name SignUpInterface
extends Interface


@onready var close_button: Button = $content/top_bar/margin/close
@onready var email_line: LineEdit = $content/margin/content/inputs/email
@onready var password_line: LineEdit = $content/margin/content/inputs/password
@onready var re_password_line: LineEdit = $content/margin/content/inputs/re_password
@onready var confirm_button: Button = $content/margin/content/buttons/confirm
@onready var back_button: Button = $content/margin/content/buttons/back


@export_group("Variables")
@export var min_password_length: int = 6

var email_regex: String = "^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"


func _ready() -> void:
	super()

	confirm_button.pressed.connect(
		_on_confirm_button_pressed
	)

	back_button.pressed.connect(
		_on_back_button_pressed
	)

	email_line.text_changed.connect(
		func(new_text: String):
			var is_valid = RegEx.create_from_string(email_regex).search(new_text) != null
			email_line.add_theme_color_override(
				"font_color", Color.RED if not is_valid else Color.WHITE
			)
	)

	password_line.text_changed.connect(
		_validate_passwords
	)

	re_password_line.text_changed.connect(
		_validate_passwords
	)


func _validate_passwords(_new_text: String = "") -> void:
	var is_valid_length = password_line.text.length() >= min_password_length
	password_line.add_theme_color_override(
		"font_color", Color.RED if not is_valid_length else Color.WHITE
	)

	var passwords_match = password_line.text == re_password_line.text
	re_password_line.add_theme_color_override(
		"font_color", Color.RED if not passwords_match else Color.WHITE
	)


func _on_confirm_button_pressed() -> void:
	var email_line_text = email_line.text
	var password_line_text = password_line.text
	var re_password_line_text = re_password_line.text

	if email_line_text.is_empty() || password_line_text.is_empty() || re_password_line_text.is_empty():
		print("Por favor, preencha todos os campos.")
		return

	confirm_button.disabled = true
	back_button.disabled = true
	close_button.disabled = true

	# envia os dados


func _on_back_button_pressed() -> void:
	WindowManager.hide_interface("sign_in")
	WindowManager.show_interface("sign_up")


func reset_ui() -> void:
	close_button.disabled = false
	confirm_button.disabled = false
	back_button.disabled = false

	email_line.clear()
	password_line.clear()
