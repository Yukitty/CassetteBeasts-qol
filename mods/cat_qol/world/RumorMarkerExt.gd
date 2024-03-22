extends "res://world/core/RumorMarker.gd"

func update_state():
	var mod: ContentInfo = DLC.mods_by_id.cat_qol
	if mod.setting_upgrade_iconmaps:
		icon = preload("res://mods/cat_qol/icons/rumor_icon_world.png")
	else:
		icon = preload("res://ui/icons/position_markers/rumor_icon_world.png")

	.update_state()