extends CanvasLayer


var interfaces: Array[Interface]


func add_interface(interface: Interface) -> void:
	if interface:
		interfaces.append(interface)


func show_interface(interface_name: String) -> void:
	for interface in interfaces:
		if interface and interface.name == interface_name:
			interface.show()
			interface.set_process(true)
			break


func hide_interface(interface_name: String) -> void:
	for interface in interfaces:
		if interface and interface.name == interface_name:
			interface.hide()
			interface.set_process(false)
			break


func get_interface(interface_name: String) -> Interface:
	for interface in interfaces:
		if interface and interface.name == interface_name:
			return interface
	return null
