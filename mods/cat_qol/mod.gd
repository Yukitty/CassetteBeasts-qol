extends ContentInfo

const MOD_STRINGS := [
	preload("mod_strings.en.translation"),
]

const RESOURCES := [
	{
		"resource": "world/GramophoneInterior.tscn",
		"resource_path": "res://world/maps/interiors/GramophoneInterior.tscn",
	},
	{
		"resource": "battle/unobtained_icon_right.png",
		"resource_path": "res://ui/battle/unobtained_icon_right.png",
	},
]

const CONDITIONAL_RESOURCES := [
	{
		"resource": "global/save_state/Inventory.gd",
		"resource_path": "res://global/save_state/Inventory.gd",
		"disable_for_mods": [
			"Inventory_Deluxe",
		],
	},
	{
		"resource": "battle/OrderMenu.gd",
		"resource_path": "res://battle/ui/OrderMenu.gd",
		"disable_for_mods": [
			"slow_fleeing",
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

enum TextMovement {
	FULL,
	REDUCED,
	DISABLED,
}

# Settings
var setting_sticker_sort_mode: int = 1
var setting_campsite_fast_travel: bool = false setget _set_campsite_fast_travel
var setting_rare_noise_enabled: bool = true
var setting_bootleg_rarity: int = 1000
var setting_postbox_enabled: bool = false
var setting_text_movement: int = TextMovement.FULL
var setting_dyslexic_font: bool = false setget _set_dyslexic_font

# Submodules
var bootleg_noise: Reference = preload("bootleg_noise.gd").new()
var font_manager: Reference = preload("font_manager.gd").new()
var bbcode_patches: Reference = preload("bbcode_patches.gd").new()
var fast_travel: Reference = preload("fast_travel.gd").new()

# Mod interop
const MODUTILS: Dictionary = {
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

	# Add resources
	for def in RESOURCES:
		load(def.resource).take_over_path(def.resource_path)

	# Add conditional resources
	for def in CONDITIONAL_RESOURCES:
		enable = true
		for mod_id in def.disable_for_mods:
			if DLC.has_mod(mod_id, 0):
				enable = false
				break
		if enable:
			load(def.resource).take_over_path(def.resource_path)

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

	# Add translation callback
	DLC.mods_by_id.cat_modutils.trans_patch.add_translation_callback(bbcode_patches, "_on_translation")

	# Add StatusBubbleRight callback
	DLC.mods_by_id.cat_modutils.callbacks.connect_scene_ready("res://battle/ui/StatusBubbleRight.tscn", self, "_on_StatusBubbleRight_ready")

func _set_dyslexic_font(enabled: bool) -> void:
	setting_dyslexic_font = enabled
	# The actual font change has to be deferred because vanilla menu stuff reverts it
	DLC.get_tree().connect("idle_frame", font_manager, "change_font", [enabled], CONNECT_ONESHOT)

func _on_StatusBubbleRight_ready(status_bubble: Control) -> void:
	var unobtained_icon: TextureRect = status_bubble.get_node("GridContainer/MarginContainer4/MarginContainer/Control/UnobtainedIcon")
	unobtained_icon.texture = load("res://ui/battle/unobtained_icon_right.png")

func _set_campsite_fast_travel(enabled: bool) -> void:
	setting_campsite_fast_travel = enabled
	fast_travel.setup_campsites(enabled and fast_travel.FastTravel.ALWAYS or fast_travel.FastTravel.DISABLED)
