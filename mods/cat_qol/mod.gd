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
		"resource": "world/QuestMarkerExt.gd",
		"resource_path": "res://world/core/QuestMarker.gd",
	},
	{
		"resource": "world/RumorMarkerExt.gd",
		"resource_path": "res://world/core/RumorMarker.gd",
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
	{
		"resource": "data/MonsterSpawnProfile.gd",
		"resource_path": "res://data/spawn_config_scripts/MonsterSpawnProfile.gd",
		"disable_for_mods": [
			"cat_bootlegs",
		],
	},
	{
		"resource": "data/MonsterSpawnConfig.gd",
		"resource_path": "res://data/spawn_config_scripts/MonsterSpawnConfig.gd",
		"disable_for_mods": [
			"cat_bootlegs",
		],
	},
]


const BATTLE_ANIMATIONS_BLACKLIST = [
	"res://data/archangel_moves/monarch_bomb_voyage.tres",
]

enum TextMovement {
	FULL,
	REDUCED,
	DISABLED,
}


# Settings
var setting_sticker_sort_mode: int = 1
var setting_campsite_fast_travel: bool = true setget _set_campsite_fast_travel
var setting_battle_animations: bool = true setget _set_battle_animations
var setting_rare_noise_enabled: bool = true
var setting_bootleg_rarity: int = 1000
var setting_show_roamers: bool = false setget _set_show_roamers
var setting_show_merchant: bool = false setget _set_show_merchant
var setting_upgrade_iconmaps: bool = true setget _set_color_in_map
var setting_postbox_enabled: bool = false
var setting_text_movement: int = TextMovement.FULL
var setting_dyslexic_font: bool = false setget _set_dyslexic_font

var map_displays: Array = []
var latest_traveling_merchant_quest: Node

var roamers_quests: Array = []
var editable_mapicons: Array = []
var passive_mapicons: Array = []
var campsite_overworld: Array = []

# Submodules
var bootleg_noise: Reference = preload("bootleg_noise.gd").new()
var font_manager: Reference = preload("font_manager.gd").new()
var bbcode_patches: Reference = preload("bbcode_patches.gd").new()
var fast_travel: Reference = preload("fast_travel.gd").new()
var color_mapicons: Reference = preload("color_mapicons.gd").new()

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
				1000,
				750,
				500,
				250,
			],
			"value_labels": [
				"UI_SETTINGS_CAT_QOL_BOOTLEG_RARITY_DEFAULT",
				"UI_SETTINGS_CAT_QOL_BOOTLEG_RARITY_RARE",
				"UI_SETTINGS_CAT_QOL_BOOTLEG_RARITY_UNCOMMON",
				"UI_SETTINGS_CAT_QOL_BOOTLEG_RARITY_COMMON",
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
			"property": "setting_show_merchant",
			"type": "toggle",
			"label": "UI_SETTINGS_CAT_QOL_SHOW_TRAVELING_MERCHANT",
		},
		{
			"property": "setting_upgrade_iconmaps",
			"type": "toggle",
			"label": "UI_SETTINGS_CAT_QOL_SHOW_COLORED_MAPICONS",
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

	# Show MissingDependencies screen if cat_modutils isn't loaded
	if not DLC.has_mod("cat_modutils", 0):
		DLC.get_tree().connect("idle_frame", SceneManager, "change_scene", ["res://mods/cat_qol/menus/MissingDependency.tscn"], CONNECT_ONESHOT)
		return

	# init submodules
	bootleg_noise.init_submodule()

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
	var modutils: Reference = DLC.mods_by_id.cat_modutils
	modutils.trans_patch.add_translation_callback(bbcode_patches, "_on_translation")
	modutils.callbacks.connect_scene_ready("res://battle/ui/StatusBubbleRight.tscn", self, "_on_StatusBubbleRight_ready")
	# traveling merchant
	modutils.callbacks.connect_scene_ready("res://data/passive_quests/TravelingMerchantQuest.tscn", self, "_on_TravelingMerchantQuest_ready")
	# each of the special spawns
	modutils.callbacks.connect_scene_ready("res://data/passive_quests/UnstableFusionQuest.tscn", self, "_on_UnstableFusionQuest_ready")
	modutils.callbacks.connect_scene_ready("res://data/passive_quests/UmbrahellaSpawnQuest.tscn", self, "_on_UmbrahellaSpawnQuest_ready")
	modutils.callbacks.connect_scene_ready("res://data/passive_quests/PicksieSpawnQuest.tscn", self, "_on_PicksieSpawnQuest_ready")
	modutils.callbacks.connect_scene_ready("res://data/passive_quests/OrbFusionQuest.tscn", self, "_on_OrbFusionQuest_ready")
	modutils.callbacks.connect_scene_ready("res://data/passive_quests/MissMimicSpawnQuest.tscn", self, "_on_MissMimicSpawnQuest_ready")
	modutils.callbacks.connect_scene_ready("res://data/passive_quests/MissMimicFusionQuest.tscn", self, "_on_MissMimicFusionQuest_ready")
	modutils.callbacks.connect_scene_ready("res://data/passive_quests/KunekosReturnQuest.tscn", self, "_on_KunekosReturnQuest_ready")
	modutils.callbacks.connect_scene_ready("res://data/passive_quests/GlaistainSpawnQuest.tscn", self, "_on_GlaistainSpawnQuest_ready")
	modutils.callbacks.connect_scene_ready("res://data/passive_quests/AverevoirSpawnQuest.tscn", self, "_on_AverevoirSpawnQuest_ready")
	# the maps
	modutils.callbacks.connect_scene_ready("res://nodes/map_display/MapDisplay.tscn", self, "_on_MapDisplay_ready")
	# quest marks
	modutils.callbacks.connect_scene_ready("res://nodes/map_display/QuestPosMarker.tscn", self, "_on_QuestMarkerDisplay_ready")
	modutils.callbacks.connect_scene_ready("res://world/ui/PersistentStatusElement_Quest.tscn", self, "_on_QuestMarkerDisplay_ready")
	# passive quest mark
	modutils.callbacks.connect_scene_ready("res://data/passive_quests/OfflineNetPlayerGiftQuest.tscn", self, "_on_PassiveQuestMarkerDisplay_ready")
	modutils.callbacks.connect_scene_ready("res://data/passive_quests/OfflineNetPlayerRematchQuest.tscn", self, "_on_PassiveQuestMarkerDisplay_ready")
	# campsites (overworld icon)
	modutils.callbacks.connect_scene_ready("res://world/core/Interaction.tscn", self, "_on_CampsiteOverworldMarkerDisplay_ready")
	
	# Init post preload
	assert(not SceneManager.preloader.singleton_setup_complete)
	yield(SceneManager.preloader, "singleton_setup_completed")

	# Set up BattleMoves
	for move in BattleMoves.moves + BattleMoves.archangel_moves.values():
		if move.resource_path in BATTLE_ANIMATIONS_BLACKLIST:
			continue
		move.set_meta("modutils_attack", {
			"fade_lights_during_attack": move.fade_lights_during_attack,
			"attack_animation": move.attack_animation,
			"attack_vfx": move.attack_vfx.duplicate(),
			"attack_duration": move.attack_duration,
			"disable_melee_movement": move.disable_melee_movement,
		})
		if not setting_battle_animations:
			move.fade_lights_during_attack = false
			move.attack_animation = ""
			move.attack_vfx.clear()
			move.attack_duration = 0
			move.disable_melee_movement = true

func _set_battle_animations(enabled: bool) -> void:
	setting_battle_animations = enabled
	if not SceneManager.preloader.singleton_setup_complete:
		return

	# Update base battle moves
	for move in BattleMoves.moves + BattleMoves.archangel_moves.values():
		if move.has_meta("modutils_attack"):
			_update_battle_move_animation(move)

	# Clear cached BattleMoves from equipped stickers
	for character in SaveState.party.characters:
		for tape in character.tapes:
			for sticker in tape.stickers:
				if sticker is StickerItem:
					sticker.modified_move = null


func _update_battle_move_animation(move: BattleMove) -> void:
	# Disable animations
	move.attack_vfx.clear()
	if not setting_battle_animations:
		move.fade_lights_during_attack = false
		move.attack_animation = ""
		move.attack_duration = 0
		move.disable_melee_movement = true
		return

	# Restore animations
	var default: Dictionary = move.get_meta("modutils_attack")
	move.fade_lights_during_attack = default.fade_lights_during_attack
	move.attack_animation = default.attack_animation
	move.attack_vfx.append_array(default.attack_vfx)
	move.attack_duration = default.attack_duration
	move.disable_melee_movement = default.disable_melee_movement


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
	unobtained_icon.texture = preload("res://ui/battle/unobtained_icon_right.png")


func _set_campsite_fast_travel(enabled: bool) -> void:
	setting_campsite_fast_travel = enabled
	fast_travel.setup_campsites(enabled and fast_travel.FastTravel.ALWAYS or fast_travel.FastTravel.DISABLED)

######################
# settings listeners #
######################
func _set_color_in_map(enabled: bool) -> void:
	setting_upgrade_iconmaps = enabled
	
	color_mapicons.setup_mapicons(enabled)
	
	for mapicon in editable_mapicons:
		_on_QuestMarkerDisplay_ready(mapicon)
	
	for mapicon in passive_mapicons:
		_on_PassiveQuestMarkerDisplay_ready(mapicon)
	
	for mapicon in campsite_overworld:
		_on_CampsiteOverworldMarkerDisplay_ready(mapicon)
	
	_update_map()


func _set_show_roamers(enabled: bool) -> void:
	setting_show_roamers = enabled
	
	for quest in roamers_quests:
		_set_RoamerQuest_map_icon(quest)
	
	_update_map()


func _set_show_merchant(enabled: bool) -> void:
	setting_show_merchant = enabled
	
	if latest_traveling_merchant_quest:
		_set_TravelingMerchantQuest_map_icon(latest_traveling_merchant_quest)
		_update_map()


####################
# callback methods #
####################
func _on_CampsiteOverworldMarkerDisplay_ready(scene: Node) -> void:
	if ! scene.icon_override: return
	
	var original = preload ( "res://ui/icons/map_markers/campsite_icon.png" )
	var alternative = preload ( "res://mods/cat_qol/icons/campsite_icon.png" )
	
	if scene.icon_override.resource_path.ends_with("campsite_icon.png"):
		if setting_upgrade_iconmaps:
			scene.icon_override = alternative
		else:
			scene.icon_override = original

		if !campsite_overworld.has(scene):
			campsite_overworld.push_back(scene)
			
			# currently, we have 13 campsite icons in game:
			# - 1 on the pier (DLC)
			# - 1 on the cafè
			# - 11 on the main map
			# we should not go beyond that too easy, but future proofing on 20
			var n_icons = campsite_overworld.size()
			if n_icons > 40:
				campsite_overworld = campsite_overworld.slice(21, n_icons-1)


func _on_PassiveQuestMarkerDisplay_ready(scene: Node) -> void:
	var marker = null
	if setting_upgrade_iconmaps:
		marker = preload( "res://mods/cat_qol/icons/passive_quest_icon.png" )
	else:
		marker = preload( "res://ui/icons/map_markers/passive_quest_icon.png" )
	
	scene.map_marker_icons = [ marker ]
	
	# as the user could ignore these for a while, I would prefer to track them
	# separately
	if ! passive_mapicons.has(scene):
		passive_mapicons.push_back(scene)
	
	# what is the max amount of passive quests marks at the map?
	# I would suspect something around 4
	# but better being conservative here
	var n_icons = passive_mapicons.size()
	if n_icons > 20:
		passive_mapicons = passive_mapicons.slice(10, n_icons-1)


func _on_QuestMarkerDisplay_ready(scene: Node) -> void:
	var marker = null
	if setting_upgrade_iconmaps:
		marker = preload( "res://mods/cat_qol/icons/quest_icon.png" )
	else:
		marker = preload( "res://ui/icons/map_markers/quest_icon.png" )

	if scene.name == "QuestPosMarker":
		scene.get_child(0).texture = marker
	elif scene.name == "PersistentStatusElement_Quest":
		scene.icon.texture = marker
	
	if ! editable_mapicons.has(scene):
		editable_mapicons.push_back(scene)
	
	# what is the max amount of quest marks at the map?
	# I would suspect something around 12
	# not at the same time:
	# - up to 12 accompaning fusions
	# - up to 5 vampires
	# - up to 12 captains
	# - anything else?
	# being very conservative here
	var n_icons = editable_mapicons.size()
	if n_icons > 50:
		editable_mapicons = editable_mapicons.slice(26, n_icons-1)


func _on_TravelingMerchantQuest_ready(scene: Node) -> void:
	_set_TravelingMerchantQuest_map_icon(scene)
	_update_map()

	# Store the quest so that if the player decides to change the setting we can
	# update the map icon accordingly
	latest_traveling_merchant_quest = scene


func _on_MapDisplay_ready(scene: Node) -> void:
	# Clear out any built up old MapDisplays to avoid memory leaks
	var freed_map_displays = []
	for map_display in map_displays:
		if not is_instance_valid(map_display) or map_display.is_queued_for_deletion():
			freed_map_displays.push_back(map_display)

	for map_display in freed_map_displays:
		map_displays.erase(map_display)

	# Add the new MapDisplay to the list
	map_displays.push_back(scene)


######################################
# updating mapicons helper functions #
######################################
func _update_map() -> void:
	for map_display in map_displays:
		if is_instance_valid(map_display) and ! map_display.is_queued_for_deletion():
			map_display.quest_markers_dirty = true
			map_display.refresh_map()


func _set_TravelingMerchantQuest_map_icon(scene: Node) -> void:
	var traveling_merchant_quest = scene
	
	if setting_show_merchant:
		# Set the quest title and map icon
		traveling_merchant_quest.title = "PASSIVE_QUEST_TRAVELING_MERCHANT_TITLE"
		traveling_merchant_quest.map_marker_icons = [
			preload("res://mods/cat_qol/icons/DiscountedMerchant.png")
		]
	else:
		# Remove the quest title and map icon
		traveling_merchant_quest.title = ""
		traveling_merchant_quest.map_marker_icons = []


func _set_RoamerQuest_map_icon(scene: Node) -> void:
	var roamer_quest = scene
	#sprint("loading new mapicon: %s" % roamer_quest)
	_on_UnstableFusionQuest_ready(roamer_quest)
	_on_UmbrahellaSpawnQuest_ready(roamer_quest)
	_on_PicksieSpawnQuest_ready(roamer_quest)
	_on_GlaistainSpawnQuest_ready(roamer_quest)
	_on_OrbFusionQuest_ready(roamer_quest)
	_on_MissMimicSpawnQuest_ready(roamer_quest)
	_on_MissMimicFusionQuest_ready(roamer_quest)
	_on_KunekosReturnQuest_ready(roamer_quest)
	_on_AverevoirSpawnQuest_ready(roamer_quest)


func _on_UnstableFusionQuest_ready(scene: Node) -> void:
	_on_RoamerSpawnQuest_ready("UnstableFusion.tscn", scene, 
	"PASSIVE_QUEST_UNSTABLE_FUSION_TITLE", "miniboss.png",
	"PASSIVE_QUEST_UNSTABLE_FUSION_TITLE", "anathema.png")


func _on_UmbrahellaSpawnQuest_ready(scene: Node) -> void:
	_on_RoamerSpawnQuest_ready("UmbrahellaSpawn.tscn", scene,
	"PASSIVE_QUEST_UNKNOWN_TITLE", "miniboss.png",
	"PASSIVE_QUEST_UMBRAHELLA_TITLE", "umbrahella.png")


func _on_PicksieSpawnQuest_ready(scene: Node) -> void:
	_on_RoamerSpawnQuest_ready("PicksieSpawn.tscn", scene, 
	"PASSIVE_QUEST_UNKNOWN_TITLE", "miniboss.png",
	"PASSIVE_QUEST_PICKSIE_TITLE", "picksie.png")


func _on_GlaistainSpawnQuest_ready(scene: Node) -> void:
	_on_RoamerSpawnQuest_ready("GlaistainSpawn.tscn", scene, 
	"PASSIVE_QUEST_UNKNOWN_TITLE", "miniboss.png",
	"PASSIVE_QUEST_GLAISTAIN_TITLE", "glaistain.png")


func _on_OrbFusionQuest_ready(scene: Node) -> void:
	_on_RoamerSpawnQuest_ready("OrbFusion.tscn", scene, 
	"PASSIVE_QUEST_ORB_FUSION_TITLE", "miniboss.png",
	"PASSIVE_QUEST_ORB_FUSION_TITLE", "orb.png")


func _on_MissMimicSpawnQuest_ready(scene: Node) -> void:
	_on_RoamerSpawnQuest_ready("MissMimicSpawn.tscn", scene, 
	"PASSIVE_QUEST_UNKNOWN_TITLE", "miniboss.png",
	"PASSIVE_QUEST_MISS_MIMIC_TITLE", "miss_mimic.png")


func _on_MissMimicFusionQuest_ready(scene: Node) -> void:
	_on_RoamerSpawnQuest_ready("MissMimicFusion.tscn", scene, 
	"PASSIVE_QUEST_ROGUE_FUSION_TITLE", "miniboss.png",
	"PASSIVE_QUEST_MISS_MIMIC_FUSION_TITLE", "miss_mimic.png")


func _on_KunekosReturnQuest_ready(scene: Node) -> void:
	_on_RoamerSpawnQuest_ready("KunekosReturn.tscn", scene, 
	"PASSIVE_QUEST_UNKNOWN_TITLE", "miniboss.png",
	"PASSIVE_QUEST_KUNEKO_TITLE", "kuneko.png")


func _on_AverevoirSpawnQuest_ready(scene: Node) -> void:
	_on_RoamerSpawnQuest_ready("AverevoirSpawn.tscn", scene, 
	"PASSIVE_QUEST_UNKNOWN_TITLE", "miniboss.png",
	"PASSIVE_QUEST_AVEREVOIR_TITLE", "averevoir.png")


func _on_RoamerSpawnQuest_ready(name: String, scene: Node,
		title: String, mapicon: String,
		alt_title: String, alt_mapicon: String) -> void:
	if !scene.spawn_scenes[0].ends_with(name):
		return

	_set_title_and_mapicon_to_roamer_scene(scene, 
		title, mapicon, alt_title, alt_mapicon)


func _set_title_and_mapicon_to_roamer_scene(scene: Node, title: String, mapicon: String,
	alt_title: String, alt_mapicon: String) -> void:
	if setting_show_roamers:
		scene.title = alt_title
		scene.map_marker_icons = [ load("res://mods/cat_qol/icons/" + alt_mapicon) ]
	else:
		scene.title = title
		scene.map_marker_icons = [ load("res://ui/icons/map_markers/" + mapicon) ]
	
	if ! roamers_quests.has(scene):
		roamers_quests.push_back(scene)

	# there is a maximum of 12 spawns at the map, including black shuk and the merchant,
	# so this limit is more than enough (to avoid memory leaks)
	if roamers_quests.size() > 12:
		roamers_quests.pop_front()
