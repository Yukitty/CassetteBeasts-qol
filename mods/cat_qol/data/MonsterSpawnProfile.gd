extends "res://data/spawn_config_scripts/MonsterSpawnProfile.gd"

func choose_config(rand: Random = null) -> SpawnConfig:
	var oresult: MonsterSpawnConfig = .choose_config(rand)

	# Late loading the script here allows mods to replace it.
	# The class_name cannot be replaced.
	var result = load("res://data/spawn_config_scripts/MonsterSpawnConfig.gd").new()
	result.world_monster = oresult.world_monster
	result.monster_forms = oresult.monster_forms
	result.disable_fleeing = oresult.disable_fleeing
	return result
