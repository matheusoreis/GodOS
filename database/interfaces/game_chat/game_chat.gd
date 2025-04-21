class_name GameChat
extends Interface

@export_group("Objects")
@onready var _messages_rich: RichTextLabel = %Messages
@onready var _message_line: LineEdit = %Message
@onready var _send_button: Button = %Send

@export_group("Variables")
@export var min_message_length: int = 3
@export var max_message_length: int = 150

var _message_regex: String = "^\\s*\\S.*$"


func _ready() -> void:
	super()

	_send_button.pressed.connect(
		func():
			var message_text = _message_line.text

			if message_text.is_empty():
				print("Por favor, preencha todos os campos.")
				return

			_send_button.disabled = true
			_server_receive_message.rpc_id(1, message_text)
	)

	_message_line.text_changed.connect(
		func(new_text: String):
			var valid_length = new_text.length() >= min_message_length and new_text.length() <= max_message_length
			var is_valid = RegEx.create_from_string(_message_regex).search(new_text) != null

			var message_valid = valid_length and is_valid

			_send_button.disabled = not message_valid

			# Define a cor com base na validade geral
			_message_line.add_theme_color_override(
				"font_color", Color.RED if not message_valid else Color.WHITE
			)
	)

	_message_line.focus_entered.connect(
		func():
			Globals.is_typing = true
	)

	_message_line.focus_exited.connect(
		func():
			Globals.is_typing = false
	)


func _reset_ui() -> void:
	_send_button.disabled = false
	_message_line.clear()


@rpc("any_peer", "call_remote")
func _server_receive_message(message: String) -> void:
	if message.length() < min_message_length or message.length() > max_message_length:
		return

	var sender_id: int = multiplayer.get_remote_sender_id()
	var connection: Dictionary = Globals.users.get(sender_id, {})
	var actor: Dictionary = connection.get("actor", {})

	if not actor.has("name"):
		return

	_display_received_message.rpc([actor["name"], message])


@rpc("authority", "call_local")
func _display_received_message(data: Array) -> void:
	var sender_name = data[0]
	var message = data[1]

	_messages_rich.append_text("[color=green]" + sender_name + ":[/color] " + message + "\n")
	_reset_ui()
