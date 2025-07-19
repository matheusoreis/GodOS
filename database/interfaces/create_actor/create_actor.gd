class_name CreateActorInterface
extends PanelContainer


@export_category("Nodes")
@export var _name_input: LineEdit
@export var _back_button: Button
@export var _create_button: Button
@export var _previous_button: Button
@export var _next_button: Button
@export var _sprite: TextureRect

@export_category("Messages")
@export var _invalid_name_message: String = "O nome precisa ter ao menos 4 caracteres."
@export var _user_not_found_message: String = "Não foi possível te localizar no servidor!"

@export_category("References")
@export var _actor_list_interface: ActorListInterface


@export_category("Notification")
@export var _shared_canvas: CanvasLayer
@export var _notification_scene: PackedScene

@export_category("Sprites")
@export var _sprites: Array[CompressedTexture2D]


var _current_sprite: int
var _selected_sprite_filename: String = ""


func request_sprites() -> void:
	set_sprites_request.rpc_id(1)


func _ready() -> void:
	_create_button.pressed.connect(_on_create_button_pressed)
	_back_button.pressed.connect(_on_back_button_pressed)

	_previous_button.pressed.connect(_on_previous_button_pressed)
	_next_button.pressed.connect(_on_next_button_pressed)


func _on_previous_button_pressed() -> void:
	if _sprites.is_empty():
		return

	_current_sprite = (_current_sprite - 1 + _sprites.size()) % _sprites.size()
	_update_sprite_display()


func _on_next_button_pressed() -> void:
	if _sprites.is_empty():
		return

	set_current_sprite(_current_sprite + 1)


func _update_sprite_display() -> void:
	var texture := _sprites[_current_sprite]
	apply_sprite_to_texture(texture)

	var path := texture.resource_path
	_selected_sprite_filename = path.get_file()


func _on_create_button_pressed() -> void:
	var actor_name: String = _name_input.text

	if actor_name.length() <= 3:
		_show_notification([_invalid_name_message])
		return

	_name_input.editable = false
	_create_button.disabled = true
	_back_button.disabled = true

	_create_actor_request.rpc_id(1, {
		"name": actor_name,
		"sprite": _selected_sprite_filename
	})


func _on_back_button_pressed() -> void:
	_actor_list_interface.show()
	hide()


@rpc("any_peer")
func set_sprites_request() -> void:
	var peer_id = multiplayer.get_remote_sender_id()

	# Definições das sprites
	# TODO: Obter pela api
	var sprites = [
		"res://assets/graphics/entities/001-Fighter01.png",
		"res://assets/graphics/entities/002-Fighter02.png",
		"res://assets/graphics/entities/003-Fighter03.png",
		"res://assets/graphics/entities/004-Fighter04.png",
		"res://assets/graphics/entities/005-Fighter05.png",
		"res://assets/graphics/entities/006-Fighter06.png",
		"res://assets/graphics/entities/007-Fighter07.png",
		"res://assets/graphics/entities/008-Fighter08.png",
		"res://assets/graphics/entities/009-Lancer01.png",
		"res://assets/graphics/entities/010-Lancer02.png",
		"res://assets/graphics/entities/011-Lancer03.png",
		"res://assets/graphics/entities/012-Lancer04.png",
		"res://assets/graphics/entities/013-Warrior01.png",
		"res://assets/graphics/entities/014-Warrior02.png",
		"res://assets/graphics/entities/015-Warrior03.png",
		"res://assets/graphics/entities/016-Thief01.png",
		"res://assets/graphics/entities/017-Thief02.png",
		"res://assets/graphics/entities/018-Thief03.png",
		"res://assets/graphics/entities/019-Thief04.png",
		"res://assets/graphics/entities/020-Hunter01.png",
		"res://assets/graphics/entities/021-Hunter02.png",
		"res://assets/graphics/entities/022-Hunter03.png",
		"res://assets/graphics/entities/023-Gunner01.png",
		"res://assets/graphics/entities/024-Gunner02.png",
		"res://assets/graphics/entities/025-Cleric01.png",
		"res://assets/graphics/entities/026-Cleric02.png",
		"res://assets/graphics/entities/027-Cleric03.png",
		"res://assets/graphics/entities/028-Cleric04.png",
		"res://assets/graphics/entities/029-Cleric05.png",
		"res://assets/graphics/entities/030-Cleric06.png",
		"res://assets/graphics/entities/031-Cleric07.png",
		"res://assets/graphics/entities/032-Cleric08.png",
		"res://assets/graphics/entities/033-Mage01.png",
		"res://assets/graphics/entities/034-Mage02.png",
		"res://assets/graphics/entities/035-Mage03.png",
		"res://assets/graphics/entities/036-Mage04.png",
		"res://assets/graphics/entities/037-Mage05.png",
		"res://assets/graphics/entities/038-Mage06.png",
		"res://assets/graphics/entities/039-Mage07.png",
		"res://assets/graphics/entities/040-Mage08.png",
		"res://assets/graphics/entities/041-Mage09.png",
	]

	set_sprites_response.rpc_id(peer_id, sprites)


@rpc("authority")
func set_sprites_response(sprites: Array) -> void:
	for path in sprites:
		var texture := load(path) as CompressedTexture2D
		if texture:
			_sprites.append(texture)

	if not _sprites.is_empty():
		_current_sprite = 0
		_update_sprite_display()


func set_current_sprite(index: int) -> void:
	if _sprites.is_empty():
		return
	_current_sprite = index % _sprites.size()
	_update_sprite_display()


func apply_sprite_to_texture(texture: CompressedTexture2D) -> void:
	var atlas: AtlasTexture
	atlas = _sprite.texture.duplicate() as AtlasTexture
	atlas.atlas = texture

	_sprite.texture = atlas


@rpc("any_peer")
func _create_actor_request(data: Dictionary) -> void:
	var peer_id = multiplayer.get_remote_sender_id()

	var user: Dictionary = ServerGlobals.users.get(peer_id, null)
	if user == null:
		_respond_with_error(peer_id, [_user_not_found_message])
		return

	var account_id: int = user["id"]
	var sprite_filename: String = data.get("sprite", "")

	var actor_name: String = data.name
	if actor_name.length() < 3:
		_respond_with_error(peer_id, [_invalid_name_message])
		return

	var endpoint = ServerConstants.backend_endpoint + "actor"
	var headers := {"Content-Type": "application/json"}
	var body := {
		"accountId": account_id,
		"name": actor_name,
		"sprite": sprite_filename,
		"mapId": 1,
		"positionX": 32,
		"positionY": 32
	}

	var result := await Fetch.fetch_json(HTTPClient.METHOD_POST, endpoint, body, headers)
	var status_code = result[1]
	var response_data = result[2]

	if status_code != 201:
		_respond_with_error(peer_id, Fetch.format_errors(response_data))
		return

	_create_actor_response.rpc_id(peer_id, [response_data, []])


func _respond_with_error(peer_id: int, message: Array) -> void:
	_create_actor_response.rpc_id(peer_id, [{}, message])


@rpc("authority")
func _create_actor_response(data: Array) -> void:
	var success: Dictionary = data[0]
	var error: Array = data[1]

	if not error.is_empty():
		reset_form()
		_show_notification(error)
		return

	reset_form()
	hide()

	_actor_list_interface.show()
	_actor_list_interface.add_actor_slot(success)


func _show_notification(messages: Array) -> void:
	var notification_interface: NotificationInterface = _notification_scene.instantiate()
	notification_interface.set_message(messages)
	_shared_canvas.add_child(notification_interface)


func reset_form() -> void:
	_name_input.clear()
	_name_input.editable = true
	_create_button.disabled = false
	_back_button.disabled = false

	_current_sprite = 0
	_selected_sprite_filename = ""
