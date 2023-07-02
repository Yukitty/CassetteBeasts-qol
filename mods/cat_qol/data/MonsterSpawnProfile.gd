extends "res://data/spawn_config_scripts/MonsterSpawnProfile.gd"


func choose_config(rand: Random = null) -> SpawnConfig:
	var oresult: MonsterSpawnConfig = .choose_config(rand)

	# If the bootleg rarity setting is untouched, just return the original result
	# Don't even risk using the MonsterSpawnConfig class
	if DLC.mods_by_id.cat_qol.setting_bootleg_rarity == 1000:
		return oresult

	# Late loading the script here allows mods to replace it.
	# The class_name cannot be replaced.
	var result = load("res://data/spawn_config_scripts/MonsterSpawnConfig.gd").new()
	result.world_monster = oresult.world_monster
	result.monster_forms = oresult.monster_forms
	result.disable_fleeing = oresult.disable_fleeing
	if "level_scale_override_key" in oresult:
		result.level_scale_override_key = oresult.level_scale_override_key
	return result
