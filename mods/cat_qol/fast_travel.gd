extends Reference


func setup_campsites(enable: bool) -> void:
	var map_metadata: MapMetadata = load("res://data/map_metadata/overworld.tres")
	var chunk_metadata: Datatable = Datatables.load(map_metadata.chunk_metadata_path)
	var overworld_chunks: Dictionary = chunk_metadata.table
	map_metadata = load("res://data/map_metadata/pier/pier_map_metadata.tres")
	chunk_metadata = Datatables.load(map_metadata.chunk_metadata_path)
	var pier_chunks: Dictionary = chunk_metadata.table

	if enable:
		_add_campsite_warps_by_chunks(overworld_chunks, "res://world/maps/Overworld.tscn")
		_add_campsite_warps_by_chunks(pier_chunks, "res://dlc/01_pier/maps/pier.tscn")
	else:
		_remove_campsite_warps_by_chunks(overworld_chunks)
		_remove_campsite_warps_by_chunks(pier_chunks)


func _add_campsite_warps_by_chunks(chunks: Dictionary, warp_target_scene: String) -> void:
	var chunk: MapChunkMetadata
	for path in chunks:
		chunk = chunks[path]
		for feature in chunk.features:
			if feature.title == "MAP_FEATURE_CAMPSITE":
				feature.warp_target_scene = warp_target_scene
				feature.warp_target_chunk = chunk.chunk_index
				feature.warp_target_name = "Campsite"
				feature.warp_effect = 0


func _remove_campsite_warps_by_chunks(chunks: Dictionary) -> void:
	var chunk: MapChunkMetadata
	for path in chunks:
		chunk = chunks[path]
		for feature in chunk.features:
			if feature.title == "MAP_FEATURE_CAMPSITE":
				feature.warp_target_scene = ""
				feature.warp_target_chunk = Vector2.ZERO
				feature.warp_target_name = ""
				feature.warp_effect = 0
