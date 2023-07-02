# Use file path instead of class_name
extends "res://data/spawn_config_scripts/MonsterSpawnConfig.gd"

func _configure_world_mon(node: Node) -> Node:
	# Fetch dynamic bootleg chance from mod
	var bootleg_chance: float = 1.0 / DLC.mods_by_id.cat_qol.setting_bootleg_rarity

	# Call parent func
	node = ._configure_world_mon(node)

	# We only care about normal overworld monster encounters
	if not node.has_node("MonsterPalette"):
		return node

	# Get the representative monster tape and character
	var palette: MonsterPalette = node.get_node("MonsterPalette")
	var tape: TapeConfig = palette.get_node(palette.tape_path)
	var c: CharacterConfig = tape.get_parent()

	# Make the representative monster shiny or not using mod setting odds, instead of const odds.
	if c.character_kind == Character.CharacterKind.MONSTER and randf() < bootleg_chance:
		tape.type_override = [BattleSetupUtil.random_type(Random.new())]
	else:
		tape.type_override.clear()

	# Does not mess with any other bootleg odds
	return node
