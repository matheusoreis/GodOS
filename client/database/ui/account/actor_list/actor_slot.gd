class_name ActorSlotUi
extends PanelContainer


@export var identifier: Label
@export var sprite: TextureRect

var _actor: Dictionary = {}


func update_data(data: Dictionary) -> void:
	_actor = data
	identifier.text = data["identifier"]
	_update_sprite(data["sprite"])


func _on_access_button_pressed() -> void:
	Network.send_packet(Packets.SELECT_ACTOR, {
		"actorId": int(_actor["id"])
	})


func _on_delete_button_pressed() -> void:
	Confirmation.show("Deseja apagar o personagem " + _actor["identifier"] + "?")
	Confirmation.on_confirmation_pressed.connect(
		func():
			Network.send_packet(Packets.DELETE_ACTOR, {
				"actorId": int(_actor["id"])
			})
	)


func _update_sprite(sprite_filename: String) -> void:
	var texture := load("res://assets/graphics/entities/" + sprite_filename) as CompressedTexture2D

	var original := sprite.texture as AtlasTexture
	var atlas_texture := AtlasTexture.new()

	atlas_texture.region = original.region
	atlas_texture.margin = original.margin

	atlas_texture.atlas = texture
	sprite.texture = atlas_texture
