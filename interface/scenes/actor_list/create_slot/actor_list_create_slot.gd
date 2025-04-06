class_name ActorListCreateSlotUi extends PanelContainer


@export_group("Objects")
@onready var create_button: Button = $content/create


func _ready() -> void:
	create_button.pressed.connect(
		func():
			WindowManager.hide_interface("actors_list")
			WindowManager.show_interface("create_actor")
	)
