extends Reference

const BootlegNoise = preload("world/BootlegNoise.tscn")

func init_submodule() -> void:
	DLC.mods_by_id.cat_modutils.callbacks.connect_class_ready(EncounterConfig, self, "_on_EncounterConfig_ready")

func _on_EncounterConfig_ready(encounter: EncounterConfig) -> void:
	if not DLC.mods_by_id.cat_qol.setting_rare_noise_enabled:
		return

	var npc := encounter.get_parent() as NPC

	# We only care about World NPCs
	if not npc:
		return

	# We only care about the displayed sprite.
	if not npc.has_node("MonsterPalette"):
		return

	# Use the MonsterPalette to get the correct TapeConfig,
	# because the encounter monsters are shuffled.
	var palette: MonsterPalette = npc.get_node("MonsterPalette")

	# tape_path SHOULD be valid on all shiny NPCs, but just in case...
	if palette.tape_path.is_empty() or not palette.has_node(palette.tape_path):
		return

	# Get bootleg from NPC tape
	var tape: TapeConfig = palette.get_node(palette.tape_path)
	if not tape or tape.type_override.size() == 0:
		return

	# It's a bootleg, attach the noise maker
	var noise: Spatial = BootlegNoise.instance()
	npc.add_child(noise)
