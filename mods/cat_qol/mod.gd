extends ContentInfo


const MOD_STRINGS := [
	preload("mod_strings.en.translation"),
]


const RESOURCES := [
	{
		"resource": "battle/unobtained_icon_right.png",
		"resource_path": "res://ui/battle/unobtained_icon_right.png",
	},
	{
		"resource": "global/save_state/Inventory.gd",
		"resource_path": "res://global/save_state/Inventory.gd",
		"disable_for_mods": [
			"Inventory_Deluxe",
		],
	},
	{
		"resource": "menus/SpookyDialog.gd",
		"resource_path": "res://menus/spooky_dialog/SpookyDialog.gd",
		"disable_for_mods": [
			"dyslexic_font",
			"dyslexic_font_all",
		],
	},
]


const BATTLE_ANIMATIONS_BLACKLIST = [
	"res://data/archangel_moves/monarch_bomb_voyage.tres",
]


const META_ANIMSET = "catqol_animset"
const META_QUEST = "catqol_quest"


enum TextMovement {
	FULL,
	REDUCED,
	DISABLED,
}


enum Secrets {
	DISABLED,
	RUMORS,
	ALL,
}


# Settings
var setting_sticker_sort_mode: int = 1
var setting_campsite_fast_travel: bool = true setget _set_campsite_fast_travel
var setting_battle_animations: bool = true setget _set_battle_animations
var setting_rare_noise_enabled: bool = true
var setting_bootleg_rarity: int = 1000
var setting_show_roamers: bool = false setget _set_show_roamers
var setting_show_secrets: int = Secrets.DISABLED setget _set_show_secrets
var setting_postbox_enabled: bool = false
var setting_text_movement: int = TextMovement.FULL
var setting_dyslexic_font: bool = false setget _set_dyslexic_font


# Dependencies
var lmodutils: Reference


# Submodules
var bootleg_noise: Reference = preload("bootleg_noise.gd").new()
var font_manager: Reference = preload("font_manager.gd").new()
var bbcode_patches: Reference = preload("bbcode_patches.gd").new()
var fast_travel: Reference = preload("fast_travel.gd").new()


# Mod interop
const MODUTILS: Dictionary = {
	"updates": "https://gist.githubusercontent.com/Yukitty/f113b1e2c11faad763a47ebc0a867643/raw/updates.json",
	"settings": [
		{
			"property": "setting_sticker_sort_mode",
			"type": "options",
			"label": "UI_SETTINGS_CAT_QOL_STICKER_SORT",
			"values": [
				0,
				1,
			],
			"value_labels": [
				"UI_SETTINGS_CAT_QOL_STICKER_SORT_DEFAULT",
				"UI_SETTINGS_CAT_QOL_STICKER_SORT_ELEMENTS",
			],
			"disable_for_mods": [
				"Inventory_Deluxe",
			],
		},
		{
			"property": "setting_campsite_fast_travel",
			"type": "toggle",
			"label": "UI_SETTINGS_CAT_QOL_CAMPSITE_FAST_TRAVEL",
		},
		{
			"property": "setting_battle_animations",
			"type": "toggle",
			"label": "UI_SETTINGS_CAT_QOL_BATTLE_ANIMATIONS",
		},
		{
			"property": "setting_rare_noise_enabled",
			"type": "toggle",
			"label": "UI_SETTINGS_CAT_QOL_RARE_NOISE",
		},
		{
			"property": "setting_bootleg_rarity",
			"type": "options",
			"label": "UI_SETTINGS_CAT_QOL_BOOTLEG_RARITY",
			"values": [
				1000, # 1:1000
				750, # 1:750
				500, # 1:500
				250, # 1:250
#				-100, # 100:1
			],
			"value_labels": [
				"UI_SETTINGS_CAT_QOL_BOOTLEG_RARITY_DEFAULT",
				"UI_SETTINGS_CAT_QOL_BOOTLEG_RARITY_RARE",
				"UI_SETTINGS_CAT_QOL_BOOTLEG_RARITY_UNCOMMON",
				"UI_SETTINGS_CAT_QOL_BOOTLEG_RARITY_COMMON",
				"UI_SETTINGS_CAT_QOL_BOOTLEG_RARITY_DUMB",
			],
			"disable_for_mods": [
				"cat_bootlegs",
			],
		},
		{
			"property": "setting_show_roamers",
			"type": "toggle",
			"label": "UI_SETTINGS_CAT_QOL_SHOW_ROAMERS",
		},
		{
			"property": "setting_show_secrets",
			"type": "options",
			"label": "UI_SETTINGS_CAT_QOL_SHOW_SECRETS",
			"values": [
				Secrets.DISABLED,
				Secrets.RUMORS,
				Secrets.ALL,
			],
			"value_labels": [
				"UI_SETTINGS_CAT_QOL_SECRETS_DISABLED",
				"UI_SETTINGS_CAT_QOL_SECRETS_RUMORS",
				"UI_SETTINGS_CAT_QOL_SECRETS_ALL",
			],
		},
		{
			"property": "setting_postbox_enabled",
			"type": "toggle",
			"label": "UI_SETTINGS_CAT_QOL_POSTBOX",
		},
		{
			"property": "setting_dyslexic_font",
			"type": "toggle",
			"label": "UI_SETTINGS_CAT_QOL_DYSLEXIC_FONT",
			"disable_for_mods": [
				"dyslexic_font",
				"dyslexic_font_all",
			],
		},
		{
			"property": "setting_text_movement",
			"type": "options",
			"label": "UI_SETTINGS_CAT_QOL_TEXT_MOVEMENT",
			"values": [
				TextMovement.FULL,
				TextMovement.REDUCED,
				TextMovement.DISABLED,
			],
			"value_labels": [
				"UI_SETTINGS_CAT_QOL_TEXT_MOVEMENT_FULL",
				"UI_SETTINGS_CAT_QOL_TEXT_MOVEMENT_REDUCED",
				"UI_SETTINGS_CAT_QOL_TEXT_MOVEMENT_DISABLED",
			],
		},
	],
}


func init_content() -> void:
	var enable: bool

	# Add translation strings
	for translation in MOD_STRINGS:
		TranslationServer.add_translation(translation)

	# Polyfill modutils if needed.
	if DLC.has_mod("cat_modutils", 0):
		lmodutils = DLC.mods_by_id.cat_modutils
	else: # Start polyfill if cat_modutils isn't loaded.
		lmodutils = load("res://mods/cat_qol/polyfill_modutils.gd").new()

	# Add conditional resources
	for def in RESOURCES:
		enable = true
		if "disable_for_mods" in def:
			for mod_id in def.disable_for_mods:
				if DLC.has_mod(mod_id, 0):
					enable = false
					break
		if enable:
			def.resource = load("res://mods/cat_qol/" + def.resource)
			def.resource.take_over_path(def.resource_path)

	# Remove conditional settings
	for def in MODUTILS.settings:
		enable = true
		if "disable_for_mods" in def:
			for mod_name in def.disable_for_mods:
				if DLC.has_mod(mod_name, 0):
					enable = false
					break
		if not enable:
			MODUTILS.settings.erase(def)

	# Vanilla callbacks
	SceneManager.connect("scene_changed", self, "_on_SceneManager_scene_changed")

	# Mod Utils callbacks
	lmodutils.trans_patch.add_translation_callback(bbcode_patches, "_on_translation")
	lmodutils.callbacks.connect_scene_ready("res://battle/ui/StatusBubbleRight.tscn", self, "_on_StatusBubbleRight_ready")
	lmodutils.callbacks.connect_class_ready(EncounterConfig, self, "_on_EncounterConfig_ready")

	# Init post preload
	assert(not SceneManager.preloader.singleton_setup_complete)
	yield(SceneManager.preloader, "singleton_setup_completed")

	# Catch quest initialization for map markers
	SaveState.quests.connect("quest_started", self, "_on_quest_started")

	# Initialize battle move animations
	var battle_moves = Datatables.load("res://data/battle_moves")
	for move in battle_moves.table.values():
		if move.resource_path in BATTLE_ANIMATIONS_BLACKLIST:
			continue
		move.set_meta(META_ANIMSET, {
			"fade_lights_during_attack": move.fade_lights_during_attack,
			"attack_animation": move.attack_animation,
			"attack_vfx": move.attack_vfx,
			"attack_duration": move.attack_duration,
			"disable_melee_movement": move.disable_melee_movement,
		})
		if not setting_battle_animations:
			move.fade_lights_during_attack = false
			move.attack_animation = ""
			move.attack_vfx = []
			move.attack_duration = 0
			move.disable_melee_movement = true

	# Initialize status effects animations
	var status_effects = Datatables.load("res://data/status_effects")
	for se in status_effects.table.values():
		var animset: Dictionary = {
			"vfx_on_add": se.vfx_on_add,
			"vfx_on_remove": se.vfx_on_remove,
		}
		if "hit_vfx" in se:
			animset.hit_vfx = se.hit_vfx
		se.set_meta(META_ANIMSET, animset)
		if not setting_battle_animations:
			se.vfx_on_add = []
			se.vfx_on_remove = []
			if "hit_vfx" in se:
				se.hit_vfx = []


func _set_battle_animations(enabled: bool) -> void:
	setting_battle_animations = enabled
	if not SceneManager.preloader.singleton_setup_complete:
		return

	# Update base battle moves
	var battle_moves = Datatables.load("res://data/battle_moves")
	for move in battle_moves.table.values():
		if move.has_meta(META_ANIMSET):
			_update_battle_move_animation(move)

	# Update status effects
	var status_effects = Datatables.load("res://data/status_effects")
	for se in status_effects.table.values():
		if se.has_meta(META_ANIMSET):
			_update_status_effect_animation(se)

	# Clear cached BattleMoves from equipped stickers
	for character in SaveState.party.characters:
		for tape in character.tapes:
			for sticker in tape.stickers:
				if sticker is StickerItem:
					sticker.modified_move = null


func _update_battle_move_animation(move: BattleMove) -> void:
	# Disable animations
	if not setting_battle_animations:
		move.fade_lights_during_attack = false
		move.attack_animation = ""
		move.attack_vfx = []
		move.attack_duration = 0
		move.disable_melee_movement = true
		return

	# Restore animations
	var default: Dictionary = move.get_meta(META_ANIMSET)
	move.fade_lights_during_attack = default.fade_lights_during_attack
	move.attack_animation = default.attack_animation
	move.attack_vfx = default.attack_vfx
	move.attack_duration = default.attack_duration
	move.disable_melee_movement = default.disable_melee_movement


func _update_status_effect_animation(se: StatusEffect) -> void:
	# Disable animations
	if not setting_battle_animations:
		se.vfx_on_add = []
		se.vfx_on_remove = []
		if "hit_vfx" in se:
			se.hit_vfx = []
		return

	# Restore animations
	var default: Dictionary = se.get_meta(META_ANIMSET)
	se.vfx_on_add = default.vfx_on_add
	se.vfx_on_remove = default.vfx_on_remove
	if "hit_vfx" in se:
		se.hit_vfx = default.hit_vfx


func _set_dyslexic_font(enabled: bool) -> void:
	setting_dyslexic_font = enabled
	# The actual font change has to be deferred because vanilla menu stuff reverts it
	DLC.get_tree().connect("idle_frame", font_manager, "change_font", [enabled], CONNECT_ONESHOT)


func _on_SceneManager_scene_changed() -> void:
	match SceneManager.current_scene.filename:
		"res://world/maps/interiors/GramophoneInterior.tscn":
			_on_GramophoneInterior_ready()


func _on_GramophoneInterior_ready() -> void:
	var scene: Spatial = SceneManager.current_scene
	var conditional: BaseConditionalLayer = scene.get_node("ExpoConditionalLayer")
	conditional.set_script(preload("world/ModConditionalLayer.gd"))
	conditional.flag_required = "setting_postbox_enabled"
	conditional._enter_tree()


func _on_StatusBubbleRight_ready(status_bubble: Control) -> void:
	var unobtained_icon: TextureRect = status_bubble.get_node("GridContainer/MarginContainer4/MarginContainer/Control/UnobtainedIcon")
	unobtained_icon.texture = load("res://ui/battle/unobtained_icon_right.png") # Update icon cached by scene (do not use preload)


func _on_EncounterConfig_ready(encounter: EncounterConfig) -> void:
	# No edit on default setting
	if setting_bootleg_rarity == 1000:
		return

	# Get our NPC
	var world_monster: Node = encounter.get_parent()
	if not world_monster or not world_monster is NPC:
		return

	# Get spawn container (eg. ConditionalLayer)
	var container: Node = world_monster.get_parent()
	if not container:
		return

	# Find the spawner that made us, as a sibling
	var spawner: Spawner
	for sibling in container.get_children():
		if sibling is Spawner:
			for spawn in sibling.current_spawns:
				if spawn == world_monster:
					spawner = sibling as Spawner
					break
			if spawner:
				break
	if not spawner:
		return

	# All set!
	_on_Monster_spawned(spawner, world_monster, encounter)


func _on_Monster_spawned(spawner: Spawner, world_monster: NPC, encounter: EncounterConfig) -> void:
	if not spawner.spawn_profile or not spawner.spawn_profile.habitat_endless:
		return

	# Custom bootleg chance setting
	var bootleg_chance: float
	if setting_bootleg_rarity < 0:
		bootleg_chance = 1.0 + (1.0 / setting_bootleg_rarity)
	else:
		bootleg_chance = 1.0 / setting_bootleg_rarity

	# Re-roll bootleg chance on all encounter monsters.
	var tape: TapeConfig
	for c in encounter.get_children():
		tape = null
		if c is CharacterConfig and c.character_kind == Character.CharacterKind.MONSTER:
			for n in c.get_children():
				if n is TapeConfig:
					tape = n
					break
			if not tape:
				continue
			if randf() < bootleg_chance:
				tape.type_override = [BattleSetupUtil.random_type(Random.new())]
#			else:
#				tape.type_override.clear()

	var monster_palette_path: NodePath = "MonsterPalette"
	if world_monster.has_node(monster_palette_path):
		var palette: MonsterPalette = world_monster.get_node(monster_palette_path)
		palette.update_palette()



func _set_campsite_fast_travel(enabled: bool) -> void:
	setting_campsite_fast_travel = enabled
	fast_travel.setup_campsites(enabled)


func _set_show_roamers(enabled: bool) -> void:
	setting_show_roamers = enabled
	for quest in SaveState.quests.get_quests_of_kind(Quest.QuestKind.PASSIVE):
		_update_quest_map_icon(quest)


func _set_show_secrets(value: int) -> void:
	setting_show_secrets = value
	for quest in SaveState.quests.get_quests_of_kind(Quest.QuestKind.PASSIVE):
		_update_quest_map_icon(quest)


func _on_quest_started(quest: Quest) -> void:
	match quest.filename:
		"res://data/passive_quests/SwarmQuest.tscn":
			_init_spoiler_quest(quest, "PASSIVE_QUEST_SWARM_TITLE", "swarm", setting_show_roamers)
		"res://data/passive_quests/UnstableFusionQuest.tscn":
			_init_spoiler_quest(quest, "PASSIVE_QUEST_UNSTABLE_FUSION_TITLE", "anathema", setting_show_roamers)
		"res://data/passive_quests/OrbFusionQuest.tscn":
			_init_spoiler_quest(quest, "PASSIVE_QUEST_ORB_FUSION_TITLE", "orb", setting_show_roamers)
		"res://data/passive_quests/GlaistainSpawnQuest.tscn":
			_init_spoiler_quest(quest, "PASSIVE_QUEST_GLAISTAIN_TITLE", "glaistain", setting_show_roamers)
		"res://data/passive_quests/AverevoirSpawnQuest.tscn":
			_init_spoiler_quest(quest, "PASSIVE_QUEST_AVEREVOIR_TITLE", "averevoir", setting_show_roamers)
		"res://data/passive_quests/KunekosReturnQuest.tscn":
			_init_spoiler_quest(quest, "PASSIVE_QUEST_KUNEKO_TITLE", "kuneko", setting_show_roamers)
		"res://data/passive_quests/MissMimicSpawnQuest.tscn":
			_init_spoiler_quest(quest, "PASSIVE_QUEST_MISS_MIMIC_TITLE", "miss_mimic", setting_show_roamers)
		"res://data/passive_quests/MissMimicFusionQuest.tscn":
			_init_spoiler_quest(quest, "PASSIVE_QUEST_MISS_MIMIC_FUSION_TITLE", "miss_mimic", setting_show_roamers)
		"res://data/passive_quests/PicksieSpawnQuest.tscn":
			_init_spoiler_quest(quest, "PASSIVE_QUEST_PICKSIE_TITLE", "picksie", setting_show_roamers)
		"res://data/passive_quests/UmbrahellaSpawnQuest.tscn":
			_init_spoiler_quest(quest, "PASSIVE_QUEST_UMBRAHELLA_TITLE", "umbrahella", setting_show_roamers)
		"res://data/passive_quests/MinosteamSpawnQuest.tscn":
			_init_spoiler_quest(quest, "PASSIVE_QUEST_MINOSTEAM_TITLE", "minosteam", setting_show_roamers)
		"res://data/passive_quests/TravelingMerchantQuest.tscn":
			_init_spoiler_quest(quest, "TRAVELING_MERCHANT_NAME", "traveling_merchant", setting_show_secrets != Secrets.DISABLED)
		"res://data/passive_quests/BlackShuckQuest.tscn":
			_init_spoiler_quest(quest, "PASSIVE_QUEST_UNKNOWN_TITLE", "black_shuck", setting_show_secrets == Secrets.ALL)


func _init_spoiler_quest(quest: Quest, title: String, icon: String, reveal: bool) -> void:
	var meta: Dictionary = {
		"title": quest.title,
		"map_marker": quest.map_marker_icons,
		"spoiler_title": title,
		"spoiler_icon": "res://mods/cat_qol/icons/" + icon + ".png",
		"revealed": reveal,
	}
	quest.set_meta(META_QUEST, meta)
	if reveal:
		quest.title = meta.spoiler_title
		quest.map_marker_icons = [ load(meta.spoiler_icon) ]


func _update_quest_map_icon(quest: Quest) -> void:
	if not quest.has_meta(META_QUEST):
		return

	var meta: Dictionary = quest.get_meta(META_QUEST)
	var reveal: bool = false
	match quest.filename:
		"res://data/passive_quests/SwarmQuest.tscn",\
		"res://data/passive_quests/UnstableFusionQuest.tscn",\
		"res://data/passive_quests/OrbFusionQuest.tscn",\
		"res://data/passive_quests/GlaistainSpawnQuest.tscn",\
		"res://data/passive_quests/AverevoirSpawnQuest.tscn",\
		"res://data/passive_quests/KunekosReturnQuest.tscn",\
		"res://data/passive_quests/MissMimicSpawnQuest.tscn",\
		"res://data/passive_quests/MissMimicFusionQuest.tscn",\
		"res://data/passive_quests/PicksieSpawnQuest.tscn",\
		"res://data/passive_quests/UmbrahellaSpawnQuest.tscn",\
		"res://data/passive_quests/MinosteamSpawnQuest.tscn":
			reveal = setting_show_roamers
		"res://data/passive_quests/TravelingMerchantQuest.tscn":
			reveal = setting_show_secrets != Secrets.DISABLED
		"res://data/passive_quests/BlackShuckQuest.tscn":
			reveal = setting_show_secrets == Secrets.ALL

	# Nothing to update.
	if reveal == meta.revealed:
		return

	# Show/hide spoiler title and icon.
	if reveal:
		quest.title = meta.spoiler_title
		quest.map_marker_icons = [ load(meta.spoiler_icon) ]
	else:
		quest.title = meta.title
		quest.map_marker_icons = meta.map_marker
	meta.revealed = reveal
	quest.emit_signal("map_markers_changed", quest)
