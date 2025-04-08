class_name Monster
extends Entity


@export_group("Objects")
@onready var aggro: Aggro = $Aggro


@export_group("Attributes")
@onready var damage: Damage = $Attributes/Damage
@onready var defense: Defense = $Attributes/Defense


func _ready() -> void:
	if aggro:
		aggro.entered.connect(_on_actor_entered)
		aggro.exited.connect(_on_actor_exited)


func _on_actor_entered(actor: Actor) -> void:
	print("Actor entrou no aggro!")


func _on_actor_exited(actor: Actor) -> void:
	print("Actor saiu do aggro!")
