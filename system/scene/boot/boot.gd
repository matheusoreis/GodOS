extends Node2D


@export var client_scene: PackedScene
@export var server_scene: PackedScene


func _on_b_1_pressed() -> void:
    var scene = client_scene.instantiate()
    scene.name = 'Main'

    get_tree().root.add_child(scene)
    queue_free()


func _on_b_2_pressed() -> void:
    var scene = server_scene.instantiate()
    scene.name = 'Main'

    get_tree().root.add_child(scene)
    queue_free()
