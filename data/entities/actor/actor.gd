class_name Actor
extends Entity


@export_group("Objects")
@onready var controller: Controller = $Controller
@onready var camera: ActorCamera = $Camera

@export_group("Attributes")
@onready var damage: Damage = $Attributes/Damage
@onready var defense: Defense = $Attributes/Defense
@onready var mana: Mana = $Attributes/Mana


func _ready() -> void:
	if name.to_int() != multiplayer.get_unique_id():
		_remove_remote_componentes()
		return


func _remove_remote_componentes() -> void:
	controller.queue_free()
	camera.queue_free()


func set_identifier(identifier: String) -> void:
	_identifier.set_identifier(identifier)
