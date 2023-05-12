extends "res://menus/spooky_dialog/SpookyDialog.gd"

const FORMAT_DISABLED = "[center]{0}[/center]"

func display() -> GDScriptFunctionState:
	var func_state: GDScriptFunctionState = .display()

	var mod: ContentInfo = DLC.mods_by_id.cat_qol
	match mod.setting_text_movement:
		mod.TextMovement.FULL:
			pass
		mod.TextMovement.REDUCED:
			# Pass FORMAT to the translation server,
			# giving the mod to change BBCode tags automatically.
			label.parse_bbcode(tr(FORMAT).format([text]))
			label.reset()
		mod.TextMovement.DISABLED:
			# It would be inappropriate to make this font bold,
			# so just remove the shake tag entirely.
			label.parse_bbcode(FORMAT_DISABLED.format([text]))
			label.reset()

	return func_state
