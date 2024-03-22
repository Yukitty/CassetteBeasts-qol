extends Reference

const MAP_METADATA: MapMetadata = preload("res://data/map_metadata/overworld.tres")

const campsite_icon: Array = [
	preload("res://ui/icons/map_markers/campsite_icon.png"),
	preload("res://mods/cat_qol/icons/campsite_icon.png")
]
const cafe_icon: Array = [
	preload("res://ui/icons/map_markers/home_icon.png"),
	preload("res://mods/cat_qol/icons/home_icon.png")
]
const ranger_icon: Array = [
	preload("res://ui/icons/map_markers/home_icon.png"),
	preload("res://mods/cat_qol/icons/home_icon1.png")
]

func setup_mapicons(add_color: bool) -> void:
	var chunk_metadata: Datatable = Datatables.load(MAP_METADATA.chunk_metadata_path)
	var index = 0
	if add_color: index = 1

	for path in chunk_metadata.table:
		var chunk: MapChunkMetadata = chunk_metadata.table[path]
		for feature in chunk.features:
			if feature.title == "MAP_FEATURE_CAMPSITE":
				feature.icon = campsite_icon[index]
			elif feature.title == "REGION_NAME_CAFE":
				feature.icon = cafe_icon[index]
			elif feature.title == "REGION_NAME_RANGER_OUTPOST":
				feature.icon = ranger_icon[index]
	
	if ! DLC.has_dlc("pier"): return
	
	var pier_metadata: MapMetadata = load("res://data/map_metadata/pier/pier_map_metadata.tres")
	chunk_metadata = Datatables.load(pier_metadata.chunk_metadata_path)
	for path in chunk_metadata.table:
		var chunk: MapChunkMetadata = chunk_metadata.table[path]
		for feature in chunk.features:
			if feature.title == "MAP_FEATURE_CAMPSITE":
				feature.icon = campsite_icon[index]
	
