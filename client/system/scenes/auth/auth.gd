extends Control


@export var sign_in_ui: SignInUi
@export var sign_up_ui: SignUpUi


func _ready() -> void:
	Network.logger.connect(_on_network_logger)
	
	Network.registry = [
		[Packets.SIGN_IN, sign_in_ui.handle],
		[Packets.SIGN_UP, sign_up_ui.handle]
	]
	
	Network.connect_to_host(Constants.host, Constants.port, Constants.secure)


func _on_network_logger(message: String) -> void:
	Alert.show(message)
