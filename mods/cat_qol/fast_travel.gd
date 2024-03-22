extends Reference

const MAP_METADATA: MapMetadata = preload("res://data/map_metadata/overworld.tres")

enum FastTravel {
	DISABLED,
	ALWAYS,
	REQUIRE_STATION,
}

func setup_campsites(mode: int) -> void:
	var chunk_metadata: Datatable = Datatables.load(MAP_METADATA.chunk_metadata_path)
	for path in chunk_metadata.table:
		var chunk: MapChunkMetadata = chunk_metadata.table[path]
		for feature in chunk.features:
			if feature.title == "MAP_FEATURE_CAMPSITE":
				match mode:
					FastTravel.ALWAYS:
						feature.warp_target_scene = "res://world/maps/Overworld.tscn"
						feature.warp_target_chunk = chunk.chunk_index
						feature.warp_target_name = "Campsite"
						feature.warp_effect = 0
					FastTravel.DISABLED, _:
						feature.warp_target_scene = ""
						feature.warp_target_chunk = Vector2.ZERO
						feature.warp_target_name = ""
						feature.warp_effect = 0
	
	if ! DLC.has_dlc("pier"): return
	
	Console.Log("HAS pier DLC!")
	var pier_metadata: MapMetadata = load("res://data/map_metadata/pier/pier_map_metadata.tres")
	chunk_metadata = Datatables.load(pier_metadata.chunk_metadata_path)
	for path in chunk_metadata.table:
		var chunk: MapChunkMetadata = chunk_metadata.table[path]
		for feature in chunk.features:
			if feature.title == "MAP_FEATURE_CAMPSITE":
				match mode:
					FastTravel.ALWAYS:
						feature.warp_target_scene = "res://dlc/01_pier/maps/pier.tscn"
						feature.warp_target_chunk = chunk.chunk_index
						feature.warp_target_name = "Campsite"
						feature.warp_effect = 0
					FastTravel.DISABLED, _:
						feature.warp_target_scene = ""
						feature.warp_target_chunk = Vector2.ZERO
						feature.warp_target_name = ""
						feature.warp_effect = 0
