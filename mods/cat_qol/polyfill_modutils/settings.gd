extends Reference

# Constants
const ModsTab: PackedScene = preload("settings/ModsTab.tscn")
const CFG_PATH: String = "user://mod_settings.cfg"

# State
var _mod: Reference = DLC.mods_by_id.cat_qol


func _init(modutils: Reference) -> void:
	modutils.callbacks.connect_scene_ready("res://menus/settings/SettingsMenu.tscn", self, "_on_SettingsMenu_ready")

	# Finish init later
	assert(not SceneManager.preloader.singleton_setup_complete)
	yield(SceneManager.preloader, "singleton_setup_completed")

	# Restore saved cfg values for loaded mods.
	var cfg := ConfigFile.new()
	cfg.load(CFG_PATH)
	for widget in _mod.MODUTILS.settings:
		if widget.type == "action":
			_init_action(_mod, widget, cfg.get_value(_mod.id, widget.action, ""))
		else:
			_mod.set(widget.property, cfg.get_value(
				_mod.id, widget.property, _mod.get(widget.property)
			))


func _on_SettingsMenu_ready(scene: Control) -> void:
	var tab: Control = ModsTab.instance()
	scene.content_container.add_child(tab)
	tab.visible = false
	scene.tabs.insert(3, {
		"name": _mod.name,
		"node": tab,
	})


func _init_action(_mod: ContentInfo, widget: Dictionary, saved_keys: String) -> void:
	assert("action" in widget)
	if not "action" in widget:
		return

	InputMap.add_action(widget.action)

	# Add gamepad input
	if "button" in widget:
		var button := InputEventJoypadButton.new()
		button.button_index = widget.button
		button.pressed = true
		InputMap.action_add_event(widget.action, button)

	# Restore cfg
	if not saved_keys.empty():
		var parse_result: JSONParseResult = JSON.parse(saved_keys)
		if not parse_result.result is Array:
			push_error("Mod Utils: Corrupt saved keybinds for mod action %s" % widget.action)
			return
		var keys: Array = parse_result.result
		for scancode in keys:
			var keybind := InputEventKey.new()
			if "physical" in widget and widget.physical is bool and widget.physical:
				keybind.physical_scancode = int(scancode)
			else:
				keybind.scancode = int(scancode)
			keybind.pressed = true
			InputMap.action_add_event(widget.action, keybind)
		return

	# Default keybind
	if "scancode" in widget:
		var keybind := InputEventKey.new()
		if "physical" in widget and widget.physical is bool and widget.physical:
			keybind.physical_scancode = widget.scancode
		else:
			keybind.scancode = widget.scancode
		keybind.pressed = true
		InputMap.action_add_event(widget.action, keybind)
