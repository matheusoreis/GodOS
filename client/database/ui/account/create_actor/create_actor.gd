class_name CreateActorUi
extends PanelContainer


@export var identifier_line: LineEdit

@export var texture_rect: TextureRect

@export var previous_button: Button
@export var next_button: Button
@export var back_button: Button
@export var confirm_button: Button

@export var sprites: Array[CompressedTexture2D]

@export var actor_list_ui: ActorListUi


var _current_sprite: int
var _selected_sprite: String = ""


func _ready() -> void:
	if not sprites.is_empty():
		_current_sprite = 0
		_update_sprite_display()


func _on_previous_button_pressed() -> void:
	if sprites.is_empty():
		return

	_current_sprite = (_current_sprite - 1 + sprites.size()) % sprites.size()
	_update_sprite_display()


func _on_next_button_pressed() -> void:
	if sprites.is_empty():
		return

	if sprites.is_empty():
		return

	_current_sprite = (_current_sprite + 1) % sprites.size()
	_update_sprite_display()


func _update_sprite_display() -> void:
	var texture := sprites[_current_sprite]

	var atlas: AtlasTexture
	atlas = texture_rect.texture.duplicate() as AtlasTexture
	atlas.atlas = texture

	texture_rect.texture = atlas

	var path := texture.resource_path
	_selected_sprite = path.get_file()


func _on_back_button_pressed() -> void:
	_update_sprite_display()

	hide()
	actor_list_ui.show()


func _on_confirm_pressed() -> void:
	var identifier: String = identifier_line.text

	if identifier.length() < Constants.min_identifier_length:
		Alert.show("Ops! O nome deve ter ao menos " + str(Constants.min_identifier_length) + " caracteres.")
		return

	set_form_interactive(false)

	Network.send_packet(Packets.CREATE_ACTOR, {
		"identifier": identifier,
		"sprite": _selected_sprite
	})


func set_form_interactive(value: bool) -> void:
	identifier_line.editable = value

	previous_button.disabled = !value
	back_button.disabled = !value
	confirm_button.disabled = !value

	_update_sprite_display()


func handle(data: Dictionary) -> void:
	set_form_interactive(true)

	if !data.get("success", false):
		var message: String  = data.get("message", "Erro desconhecido ao fazer login.")
		Alert.show(message)
		return

	Network.send_packet(Packets.ACTOR_LIST, {})

	hide()
	actor_list_ui.show()
