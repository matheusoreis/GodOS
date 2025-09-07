extends Node

@export var id: int
@export var identifier: String
@export var tilemap_layers: Array[TileMapLayer]

func _ready() -> void:
	save_all_tilemaps_to_json("user://mapa.json")

func save_all_tilemaps_to_json(file_path: String):
	var all_layers_data = {}

	for layer in tilemap_layers:
		if layer:
			var layer_data = []
			var used_rect = layer.get_used_rect()

			for y in range(used_rect.position.y, used_rect.end.y):
				for x in range(used_rect.position.x, used_rect.end.x):
					var tile_coords = Vector2i(x, y)
					var tile_data_obj = layer.get_cell_tile_data(tile_coords)

					if tile_data_obj:
						var custom_data_layers = {}

						if tile_data_obj.has_custom_data("block"):
							custom_data_layers["block"] = tile_data_obj.get_custom_data("block")

						if not custom_data_layers.is_empty():
							var entry = {
								"x": x,
								"y": y,
								"data": custom_data_layers
							}
							layer_data.append(entry)

			all_layers_data[layer.name] = layer_data

	var json_string = JSON.stringify(all_layers_data, "\t")
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("Todos os TileMapLayers foram salvos em: ", file_path)
	else:
		print("Erro ao salvar JSON: ", file_path)
