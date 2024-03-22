extends "res://world/core/QuestMarker.gd"

func update_state():
	var mod: ContentInfo = DLC.mods_by_id.cat_qol
	if mod.setting_upgrade_iconmaps:
		icon = preload("res://mods/cat_qol/icons/quest_icon_world.png")
	else:
		icon = preload("res://ui/icons/position_markers/quest_icon_world.png")

	.update_state()